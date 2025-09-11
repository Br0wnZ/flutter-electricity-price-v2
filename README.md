# 🔌 Electricity Price Flutter App

Una aplicación móvil desarrollada en Flutter para consultar precios de electricidad en tiempo real en España.

## 📋 Descripción

Esta aplicación es una **migración y modernización** de un proyecto Flutter existente que estaba desarrollado en una versión antigua del framework. El proyecto ha sido completamente refactorizado para utilizar las últimas versiones de Flutter y las mejores prácticas de desarrollo.

### 🎯 Motivo del Desarrollo

- **Migración técnica**: El proyecto original estaba en una versión obsoleta de Flutter
- **Modernización**: Actualización de arquitectura, dependencias y código
- **Aplicación funcional**: App completamente operativa con datos reales
- **Portfolio**: Showcase de capacidades técnicas en desarrollo Flutter

### ✅ Estado Actual

**La aplicación está completamente funcional y operativa:**

- ✅ **API conectada y funcionando**: Datos reales de precios de electricidad
- ✅ **Interfaz completamente responsive**: Optimizada para todos los dispositivos
- ✅ **Gestión de estados robusta**: Implementación BLoC completa
- ✅ **Manejo de errores elegante**: Recuperación automática y reintentos
- ✅ **Notificaciones locales**: Sistema de alertas implementado
- ✅ **Temas dinámicos**: Soporte completo para modo claro/oscuro
- ✅ **Build para producción**: APK/AAB listos para distribución

## ⚙️ Configuración de Environment

### 🔐 Archivos de Environment (Requeridos)

Los archivos de configuración de environment contienen información sensible como API keys y no están incluidos en el repositorio por seguridad. Debes crearlos manualmente:

#### 1. **Environment de Desarrollo**
Crea el archivo `lib/env/environment_dev.dart`:

```dart
import 'package:precioluz/app/shared/utils/environment/environment.dart';

class EnvDev implements Environment {
  static const String name = 'DEV';
  String get basePath => 'https://api.esios.ree.es/';
  String get apiKey => 'TU_API_KEY_DE_DESARROLLO_AQUI';
  bool get production => false;
}
```

#### 2. **Environment de Producción**
Crea el archivo `lib/env/environment_prod.dart`:

```dart
import 'package:precioluz/app/shared/utils/environment/environment.dart';

class EnvProd implements Environment {
  static const String name = 'PROD';
  String get basePath => 'https://api.esios.ree.es/';
  String get apiKey => 'TU_API_KEY_DE_PRODUCCION_AQUI';
  bool get production => true;
}
```

### 🔑 Obtener API Key

Para obtener tu API key de Red Eléctrica de España (REE):

1. **Regístrate** en [ESIOS - REE](https://www.esios.ree.es/es)
2. **Solicita acceso** a la API
3. **Copia tu API key** personal
4. **Reemplaza** `TU_API_KEY_AQUI` en los archivos de environment

### ⚠️ **Importante - Seguridad**

- ❌ **NUNCA** commits estos archivos al repositorio
- 🔒 **SIEMPRE** usa diferentes API keys para desarrollo y producción
- 🔐 **MANTÉN** tus API keys privadas y seguras

## 🚀 Tecnologías Utilizadas

- **Flutter** (>=3.3.0) - Framework multiplataforma
- **Dart** (>=3.3.0) - Lenguaje de programación
- **BLoC Pattern** - Gestión de estado reactiva
- **Clean Architecture** - Arquitectura escalable y mantenible
- **Material Design 3** - UI/UX moderno con Dynamic Color
- **Syncfusion Charts** - Gráficos interactivos profesionales
- **Retrofit + Dio** - Cliente HTTP robusto con interceptores
- **Connectivity Plus** - Detección de estado de red
- **Awesome Notifications** - Sistema de notificaciones avanzado

## 📱 Características Implementadas

### 🔌 **Funcionalidades Principales**
- **Consulta de precios en tiempo real**: Datos actualizados de la API de REE
- **Gráficos interactivos**: Visualización profesional de datos históricos
- **Precio promedio**: Cálculo y visualización del precio medio del día
- **Precios mínimo y máximo**: Identificación de las mejores y peores horas
- **Lista detallada por horas**: Desglose completo de precios horarios

### 🎨 **Experiencia de Usuario**
- **Tema dinámico**: Adaptación automática a los colores del sistema
- **Modo oscuro/claro**: Selector manual de tema con persistencia
- **Interfaz responsive**: Optimizada para teléfonos y tablets
- **Animaciones fluidas**: Transiciones suaves y profesionales
- **Pull-to-refresh**: Actualización manual de datos con gestos

### 🔔 **Sistema de Notificaciones**
- **Notificaciones locales**: Alertas de precios importantes
- **Configuración flexible**: Personalización de alertas por usuario

### 🌐 **Conectividad Inteligente**
- **Detección de conexión**: Monitoreo en tiempo real del estado de red
- **Reintentos automáticos**: Recuperación automática al restaurar conexión
- **Manejo de errores elegante**: UX optimizada para situaciones sin conexión

## 📦 Instalación y Configuración

### Prerequisitos

- Flutter SDK (>=3.3.0)
- Dart SDK (>=3.3.0)
- Android Studio / Xcode para desarrollo móvil

### Pasos de instalación

1. **Clona el repositorio:**
```bash
git clone https://github.com/tu-usuario/flutter_electricity_price_new.git
cd flutter_electricity_price_new
```

2. **Configura los environments:** (Ver sección anterior)
```bash
# Crea los archivos de environment según las instrucciones arriba
touch lib/env/environment_dev.dart
touch lib/env/environment_prod.dart
```

3. **Instala las dependencias:**
```bash
flutter pub get
```

4. **Genera código automático:**
```bash
flutter packages pub run build_runner build
```

5. **Ejecuta la aplicación:**
```bash
# Desarrollo
flutter run --debug

# Producción
flutter run --release
```

## 🏗️ Estructura del Proyecto

```
lib/
├── app/
│   ├── data/              # Modelos y repositorios
│   ├── domain/            # Lógica de negocio
│   ├── presentation/      # UI y BLoCs
│   ├── services/          # Servicios externos
│   ├── shared/            # Utilidades compartidas
│   └── theme/             # Sistema de temas
├── env/                   # Configuración de environments
└── main.dart             # Punto de entrada
```

## 🔨 Comandos de Build

```bash
# Build para Android
flutter build apk --release
flutter build appbundle --release

# Build para iOS
flutter build ios --release

# Build para Web
flutter build web --release

# Generar iconos
flutter packages pub run flutter_launcher_icons:main
```

## 🧪 Testing

```bash
# Ejecutar tests unitarios
flutter test

# Ejecutar tests de integración
flutter test integration_test/

# Análisis de código
flutter analyze
```

## 📊 Arquitectura y Patrones

### 🏛️ **Clean Architecture**
- **Separation of Concerns**: Capas claramente definidas
- **Dependency Inversion**: Inyección de dependencias con BLoC
- **Single Responsibility**: Cada clase tiene una responsabilidad única

### 🔄 **BLoC Pattern**
- **State Management**: Gestión reactiva de estados
- **Event-Driven**: Arquitectura basada en eventos
- **Testeable**: Lógica de negocio fácilmente testeable

### 🎨 **Material Design 3**
- **Dynamic Color**: Adaptación automática a colores del sistema
- **Responsive Design**: Interfaz adaptativa a diferentes pantallas
- **Accessibility**: Soporte completo para accesibilidad

## 📝 Notas Técnicas

### Migración realizada:
- ✅ **Flutter 2.x → 3.3+**: Actualización completa del framework
- ✅ **Material 2 → Material 3**: Nuevo sistema de diseño con Dynamic Color
- ✅ **Null Safety**: Implementación completa con sound null safety
- ✅ **Plugin updates**: Actualización de todas las dependencias a versiones estables
- ✅ **Build system**: Migración a Android Gradle Plugin 8.x
- ✅ **API Integration**: Conexión funcional con API de REE ESIOS

### Características técnicas implementadas:
- 🏗️ **Clean Architecture** con separación clara de capas
- 🔄 **BLoC Pattern** para gestión de estado reactiva y predecible
- 🔐 **Environment configuration** para diferentes entornos de despliegue
- 📱 **Responsive design** completamente adaptativo
- 🎨 **Dynamic theming** con soporte de Material You
- 🔔 **Local notifications** con configuración avanzada
- 🌐 **Network resilience** con reintentos automáticos y manejo de errores
- 📊 **Professional charts** con Syncfusion para visualización de datos
- 🔄 **State persistence** para mantener configuraciones de usuario

## 🚀 Rendimiento y Optimización

- **Build optimizado**: APK/AAB con ofuscación y optimización de código
- **Lazy loading**: Carga diferida de componentes pesados
- **Memory management**: Gestión eficiente de memoria con dispose automático
- **Network caching**: Cache inteligente de respuestas HTTP
- **Image optimization**: Imágenes optimizadas para diferentes densidades

## 🤝 Contribuciones

Este proyecto demuestra una migración exitosa de Flutter y está abierto a contribuciones. Si encuentras mejoras o sugerencias:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

## 📞 Contacto

Proyecto desarrollado como demostración de capacidades avanzadas en Flutter, migración de aplicaciones móviles y implementación de arquitecturas escalables.

---

**✨ Este es un proyecto completamente funcional que demuestra la migración exitosa de una aplicación Flutter legacy a las últimas versiones del framework, implementando las mejores prácticas de desarrollo móvil moderno.**