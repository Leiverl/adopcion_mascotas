
import { Component, Inject, OnInit, OnDestroy, inject, ViewChild, ElementRef, AfterViewChecked } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MAT_DIALOG_DATA, MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { ChatService, Mensaje } from '../../services/chat.service';
import { AuthService } from '../../../core/services/auth.service';
import { SolicitudAdopcion } from '../../../adopciones/services/adopciones.service';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { ReactiveFormsModule, FormControl } from '@angular/forms';
import { Subscription } from 'rxjs';

@Component({
  selector: 'app-chat-modal',
  standalone: true,
  imports: [CommonModule, MatDialogModule, MatFormFieldModule, MatInputModule, MatButtonModule, MatIconModule, ReactiveFormsModule],
  templateUrl: './chat-modal.html',
  styleUrls: ['./chat-modal.scss'],
})
export class ChatModalComponent implements OnInit, OnDestroy, AfterViewChecked {
  @ViewChild('messageList') private messageList!: ElementRef;

  private chatService = inject(ChatService);
  private authService = inject(AuthService);

  public messages: Mensaje[] = [];
  public messageControl = new FormControl('');
  public currentUserId = this.authService.getUserId();
  private messageSubscription: Subscription;
  private typingSubscription: Subscription;
  public isTyping = false;
  private typingTimeout: any;

  constructor(
    public dialogRef: MatDialogRef<ChatModalComponent>,
    @Inject(MAT_DIALOG_DATA) public data: { solicitud: SolicitudAdopcion, conversacionId: string }
  ) {
    this.messageSubscription = this.chatService.onNewMessage().subscribe(newMessage => {
      this.isTyping = false;
      this.messages.push(newMessage);
    });

    this.typingSubscription = this.chatService.onTyping().subscribe(() => {
      this.isTyping = true;
      this.scrollToBottom();
      clearTimeout(this.typingTimeout);
      this.typingTimeout = setTimeout(() => { this.isTyping = false; }, 2000);
    });
  }

  ngOnInit(): void {
    this.chatService.connect();
    this.chatService.getHistory(this.data.conversacionId).subscribe(history => {
      this.messages = history;
    });
  }

  ngAfterViewChecked(): void {
    this.scrollToBottom();
  }

  onInput() {
    this.chatService.sendTyping(this.data.conversacionId);
  }

  sendMessage(): void {
    const text = this.messageControl.value;
    if (text && text.trim() !== '') {
      this.chatService.sendMessage(this.data.conversacionId, text);
      this.messageControl.reset();
    }
  }

  scrollToBottom(): void {
    try {
      this.messageList.nativeElement.scrollTop = this.messageList.nativeElement.scrollHeight;
    } catch(err) { }
  }

  ngOnDestroy(): void {
    this.chatService.disconnect();
    this.messageSubscription.unsubscribe();
    this.typingSubscription.unsubscribe();
  }
}