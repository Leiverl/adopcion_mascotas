import { Component, inject } from '@angular/core';
import { IonicModule, Platform, isPlatform } from '@ionic/angular';
import { PushNotifications } from '@capacitor/push-notifications';
import { AuthService } from './core/auth.service';
import { addIcons } from 'ionicons';
import { 
  filterOutline, closeCircle, informationCircle, heartCircle, searchOutline,
  pawOutline, maleFemaleOutline, calendarNumberOutline, resizeOutline, heart,
  heartOutline, paw, logoGoogle, heartDislikeOutline, downloadOutline,
  documentTextOutline, settingsOutline, logOutOutline, calendarOutline,
  personOutline, personCircleOutline, locationOutline, checkmarkCircleOutline,
  alertCircleOutline, starOutline, notificationsOutline, notificationsOffOutline, trash, send, chatbubblesOutline, close
} from 'ionicons/icons';

@Component({
  selector: 'app-root',
  templateUrl: 'app.component.html',
  styleUrls: ['app.component.scss'],
  standalone: true,
  imports: [IonicModule],
})
export class AppComponent {
  private platform = inject(Platform);
  private authService = inject(AuthService);

  constructor() {
    this.initializeApp();
    
    addIcons({
      filterOutline, closeCircle, informationCircle, heartCircle, searchOutline,
      pawOutline, maleFemaleOutline, calendarNumberOutline, resizeOutline, heart,
      heartOutline, paw, logoGoogle, heartDislikeOutline, downloadOutline,
      documentTextOutline, settingsOutline, logOutOutline, calendarOutline,
      personOutline, personCircleOutline, locationOutline, checkmarkCircleOutline,
      alertCircleOutline, starOutline, notificationsOutline, notificationsOffOutline, trash, send, chatbubblesOutline, close
    });
  }

  initializeApp() {
    this.platform.ready().then(() => {
      if (isPlatform('capacitor')) {
        if (this.authService.getToken()) {
          this.registerForPushNotifications();
        }
      }
    });
  }
  
  async registerForPushNotifications() {
    await PushNotifications.requestPermissions();
    await PushNotifications.register();

    PushNotifications.addListener('registration', (token) => {
      console.log('Push registration success, token: ', token.value);
      this.authService.registerFcmToken(token.value).subscribe({
        next: () => console.log('FCM Token registered with backend.'),
        error: (err) => console.error('Error registering FCM token with backend:', err)
      });
    });

    PushNotifications.addListener('registrationError', (err) => {
      console.error('Push registration error: ', err.error);
    });

    PushNotifications.addListener('pushNotificationReceived', (notification) => {
      console.log('Push received: ', JSON.stringify(notification));
      // Aquí podrías mostrar un toast si la app está abierta
    });

    PushNotifications.addListener('pushNotificationActionPerformed', (notification) => {
      console.log('Push action performed: ', JSON.stringify(notification));
      // Aquí puedes navegar a la ruta que viene en notification.data.route
    });
  }
}