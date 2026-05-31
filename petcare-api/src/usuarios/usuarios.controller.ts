import { Controller, Post, Body, Get, UseGuards, Param, Patch, Delete, Req  } from '@nestjs/common';
import { UsuariosService } from './usuarios.service';
import { CreateUsuarioDto } from './dto/create-usuario.dto';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { AuthGuard } from '@nestjs/passport';
import { UpdateUsuarioDto } from './dto/update-usuario.dto';
import { Roles } from '../auth/decorators/roles.decorator';
import { RolesGuard } from '../auth/guards/roles.guard';

@ApiTags('usuarios')
@Controller('usuarios')
export class UsuariosController {
  constructor(private readonly usuariosService: UsuariosService) {}

  @Get('disponibles/refugio')
  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles('ADMIN')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Obtener usuarios con rol REFUGIO sin refugio asignado (Solo ADMIN)' })
  findAvailableShelterUsers() {
    return this.usuariosService.findAvailableShelterUsers();
  }

  @Post('registro')
  @ApiOperation({ summary: 'Registrar un nuevo usuario' })
  @ApiResponse({ status: 201, description: 'Usuario registrado exitosamente.'})
  @ApiResponse({ status: 409, description: 'El correo electrónico ya está registrado.'})
  create(@Body() createUsuarioDto: CreateUsuarioDto) {
    return this.usuariosService.create(createUsuarioDto);
  }

  @Get('mi-perfil')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Obtener el perfil del usuario logueado' })
  getMyProfile(@Req() req) {
    return this.usuariosService.findOne(req.user.id);
  }

  @Get()
  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles('ADMIN')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Obtener la lista de todos los usuarios (Solo ADMIN)' })
  findAll() {
    return this.usuariosService.findAll();
  }

  @Get(':id')
  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles('ADMIN')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Obtener un usuario por ID (Solo ADMIN)' })
  findOne(@Param('id') id: string) {
    return this.usuariosService.findOne(id);
  }

  @Patch('mi-perfil')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Actualizar el perfil del usuario logueado' })
  updateProfile(@Req() req, @Body() updateUsuarioDto: UpdateUsuarioDto) {
    return this.usuariosService.updateProfile(req.user.id, updateUsuarioDto);
  }

  // ── FCM TOKEN ───────────────────────────────────────────────────────────
  @Post('fcm-token')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Guardar FCM token del dispositivo del usuario logueado' })
  saveFcmToken(@Req() req, @Body('token') token: string) {
    return this.usuariosService.saveFcmToken(req.user.id, token);
  }

  @Delete('fcm-token')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Eliminar FCM token al cerrar sesión' })
  removeFcmToken(@Req() req, @Body('token') token: string) {
    return this.usuariosService.removeFcmToken(req.user.id, token);
  }

  @Patch(':id')
  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles('ADMIN')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Actualizar un usuario (Solo ADMIN)' })
  update(@Param('id') id: string, @Body() updateUsuarioDto: UpdateUsuarioDto) {
    return this.usuariosService.update(id, updateUsuarioDto);
  }

  @Delete(':id')
  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles('ADMIN')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Eliminar un usuario (Solo ADMIN)' })
  remove(@Param('id') id: string) {
    return this.usuariosService.remove(id);
  }
}
