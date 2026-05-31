import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import * as admin from 'firebase-admin';
import { Notificacion } from './schemas/notificacion.schema';
import { Usuario } from '../usuarios/schemas/usuario.schema';
import { InteraccionEvento } from '../interacciones-eventos/schemas/interaccion-evento.schema';

@Injectable()
export class NotificationsService {
  private firebaseEnabled = false;

  constructor(
    @InjectModel(Notificacion.name) private notificacionModel: Model<Notificacion>,
    @InjectModel(Usuario.name) private usuarioModel: Model<Usuario>,
    @InjectModel(InteraccionEvento.name) private interaccionModel: Model<InteraccionEvento>,
  ) {
    const serviceAccountJson = process.env.FIREBASE_SERVICE_ACCOUNT;

    if (serviceAccountJson) {
      try {
        if (admin.apps.length === 0) {
          const serviceAccount = JSON.parse(serviceAccountJson);
          admin.initializeApp({
            credential: admin.credential.cert(serviceAccount),
          });
        }
        this.firebaseEnabled = true;
        console.log('[Firebase] Inicializado correctamente desde variable de entorno.');
      } catch (e) {
        console.error('[Firebase] Error al parsear FIREBASE_SERVICE_ACCOUNT:', e);
      }
    } else {
      console.warn('[Firebase] ADVERTENCIA: FIREBASE_SERVICE_ACCOUNT no definida. Push desactivado.');
    }
  }

  async createAndSend(payload: { userId: string; title: string; body: string; route?: string }) {
    const notificacionGuardada = await new this.notificacionModel({
      usuario: payload.userId,
      titulo: payload.title,
      cuerpo: payload.body,
      ruta: payload.route,
    }).save();

    if (this.firebaseEnabled) {
      const targetUser = await this.usuarioModel.findById(payload.userId).select('fcmTokens');
      if (targetUser && targetUser.fcmTokens.length > 0) {
        const message: admin.messaging.MulticastMessage = {
          tokens: targetUser.fcmTokens,
          notification: { title: payload.title, body: payload.body },
          data: { route: payload.route || '' },
        };
        try {
          const result = await admin.messaging().sendEachForMulticast(message);
          console.log(`[Firebase] Push enviado: ${result.successCount} éxitos, ${result.failureCount} fallos.`);
        } catch (e) {
          console.error('[Firebase] Error enviando push:', e);
        }
      }
    }

    return notificacionGuardada;
  }

  async getMisNotificaciones(userId: string): Promise<Notificacion[]> {
    return this.notificacionModel.find({ usuario: userId }).sort({ createdAt: -1 }).limit(50).exec();
  }

  async sendManualNotificationToEventAttendees(eventoId: string, titulo: string, cuerpo: string) {
    const interacciones = await this.interaccionModel.find({ evento: eventoId });
    const userIds = interacciones.map(i => i.usuario);
    for (const userId of userIds) {
      await this.createAndSend({
        userId: userId.toString(),
        title: titulo,
        body: cuerpo,
        route: `/tabs/events/${eventoId}`,
      });
    }
    return { message: `Notificaciones enviadas a ${userIds.length} usuarios.` };
  }

  async remove(id: string, userId: string): Promise<{ message: string }> {
    const result = await this.notificacionModel.deleteOne({ _id: id, usuario: userId });
    if (result.deletedCount === 0) {
      throw new NotFoundException('Notificación no encontrada o no tienes permiso para eliminarla.');
    }
    return { message: 'Notificación eliminada.' };
  }

  async markAsRead(id: string, userId: string) {
    const result = await this.notificacionModel.updateOne(
      { _id: id, usuario: userId },
      { leida: true },
    );
    if (result.modifiedCount === 0) throw new NotFoundException('Notificación no encontrada.');
    return { message: 'Notificación marcada como leída.' };
  }

  async markAllAsRead(userId: string) {
    await this.notificacionModel.updateMany(
      { usuario: userId, leida: false },
      { leida: true },
    );
    return { message: 'Todas las notificaciones marcadas como leídas.' };
  }
}
