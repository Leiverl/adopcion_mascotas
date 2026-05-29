import { Component, OnInit, OnDestroy, ViewChild, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormControl, ReactiveFormsModule } from '@angular/forms';
import { IonicModule, IonContent } from '@ionic/angular';
import { ActivatedRoute, Router } from '@angular/router';
import { ChatService, Mensaje } from 'src/app/core/chat.service';
import { AuthService } from 'src/app/core/auth.service';
import { Subscription } from 'rxjs';

@Component({
  selector: 'app-chat',
  standalone: true,
  imports: [IonicModule, CommonModule, ReactiveFormsModule],
  templateUrl: './chat.page.html',
  styleUrls: ['./chat.page.scss'],
})
export class ChatPage implements OnInit, OnDestroy {
  @ViewChild(IonContent) content: IonContent | undefined;

  private route = inject(ActivatedRoute);
  private router = inject(Router);
  private chatService = inject(ChatService);
  private authService = inject(AuthService);
  
  public messages: Mensaje[] = [];
  public messageControl = new FormControl('');
  public currentUserId = this.authService.getUserData()?.id;
  private messageSubscription?: Subscription;
  private typingSubscription?: Subscription;
  private conversacionId: string = '';
  public chatPartnerName = 'Refugio';
  public isTyping = false;
  private typingTimeout: any;

  constructor() {
    // Leemos el nombre del refugio que pasamos desde la página anterior
    const navigation = this.router.getCurrentNavigation();
    this.chatPartnerName = navigation?.extras?.state?.['partnerName'] || 'Refugio';
  }

  ngOnInit() {
    // Leemos el ID de la conversación desde la URL
    this.conversacionId = this.route.snapshot.paramMap.get('conversacionId')!;
    if (!this.conversacionId) {
      console.error('No se encontró el ID de la conversación.');
      return;
    }

    this.chatService.connect();
    
    // Obtenemos el historial usando el ID de la conversación
    this.chatService.getHistory(this.conversacionId).subscribe(history => {
      this.messages = history;
      this.scrollToBottom();
    });

    // Escuchamos nuevos mensajes
    this.messageSubscription = this.chatService.onNewMessage().subscribe(newMessage => {
      this.isTyping = false;
      if (!this.messages.find(m => m._id === newMessage._id)) {
        this.messages.push(newMessage);
      }
      this.scrollToBottom();
    });

    // Escuchamos el evento "está escribiendo"
    this.typingSubscription = this.chatService.onTyping().subscribe((data) => {
      if (data.conversacionId === this.conversacionId) {
        this.isTyping = true;
        this.scrollToBottom();
        clearTimeout(this.typingTimeout);
        this.typingTimeout = setTimeout(() => {
          this.isTyping = false;
        }, 2000);
      }
    });
  }

  // Enviamos el evento "está escribiendo" al teclear
  onInput() {
    this.chatService.sendTyping(this.conversacionId);
  }

  // Enviamos el mensaje
  sendMessage() {
    const text = this.messageControl.value;
    if (text && text.trim() !== '') {
      this.chatService.sendMessage(this.conversacionId, text);
      this.messageControl.reset();
    }
  }

  scrollToBottom() {
    setTimeout(() => this.content?.scrollToBottom(300), 100);
  }

  // Limpiamos las conexiones y suscripciones al salir de la página
  ngOnDestroy() {
    this.chatService.disconnect();
    this.messageSubscription?.unsubscribe();
    this.typingSubscription?.unsubscribe();
  }
}