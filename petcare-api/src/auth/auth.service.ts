import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { UsuariosService } from '../usuarios/usuarios.service';
import { LoginUsuarioDto } from './dto/login-usuario.dto';
import * as bcrypt from 'bcrypt';
import { Model } from 'mongoose';
import { Usuario } from 'src/usuarios/schemas/usuario.schema';
import { InjectModel } from '@nestjs/mongoose';
import { OAuth2Client } from 'google-auth-library';
import { ConfigService } from '@nestjs/config';
@Injectable()
export class AuthService {
  private googleClient: OAuth2Client;
  constructor(
    @InjectModel(Usuario.name) private usuarioModel: Model<Usuario>,
    private jwtService: JwtService,
    private configService: ConfigService,
  ) {
    this.googleClient = new OAuth2Client(
      this.configService.get<string>('GOOGLE_CLIENT_ID'),
    );
  }

  async login(loginUsuarioDto: LoginUsuarioDto): Promise<{ accessToken: string }> {
    const { correo, contrasena } = loginUsuarioDto;

    const usuario = await this.usuarioModel.findOne({ correo }).select('+contrasena');

    if (!usuario) {
      throw new UnauthorizedException('Credenciales inválidas (correo)');
    }

    const contrasenaValida = await bcrypt.compare(contrasena, usuario.contrasena);

    if (!contrasenaValida) {
      throw new UnauthorizedException('Credenciales inválidas (contraseña)');
    }

    // Ahora incluimos 'nombre' en el payload del token
    const payload = {
      id: usuario._id,
      nombre: usuario.nombre,
      correo: usuario.correo,
      rol: usuario.rol,
    };

    const accessToken = this.jwtService.sign(payload);

    return { accessToken };
  }

  async loginWithGoogle(token: string): Promise<{ accessToken: string }> {
    try {
      const ticket = await this.googleClient.verifyIdToken({
        idToken: token,
        audience: this.configService.get<string>('GOOGLE_CLIENT_ID'),
      });
      const payload = ticket.getPayload();
      if (!payload) {
        throw new UnauthorizedException('Token de Google inválido.');
      }

      const { email, name, picture } = payload;

      let usuario = await this.usuarioModel.findOne({ correo: email });

      if (!usuario) {
        const newUser = {
          nombre: name,
          correo: email,
          contrasena: await bcrypt.hash(Math.random().toString(36), 10),
          fotoPerfil: picture,
          rol: 'ADOPTANTE',
        };
        usuario = await this.usuarioModel.create(newUser);
      }

      // Incluimos 'nombre' en el payload de Google Login también
      const appPayload = {
        id: usuario._id,
        nombre: usuario.nombre,
        correo: usuario.correo,
        rol: usuario.rol,
      };
      const accessToken = this.jwtService.sign(appPayload);

      return { accessToken };

    } catch (error) {
      throw new UnauthorizedException('Fallo en la autenticación con Google.');
    }
  }

  async registerFcmToken(userId: string, fcmToken: string): Promise<{ message: string }> {
    await this.usuarioModel.findByIdAndUpdate(userId, {
      $addToSet: { fcmTokens: fcmToken }
    });
    return { message: 'FCM token registered successfully' };
  }
}
