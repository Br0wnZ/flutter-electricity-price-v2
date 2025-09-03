# ⚡ Precio de la Luz - App Flutter

Una aplicación móvil desarrollada en Flutter para consultar los precios de la electricidad en España en tiempo real.

## 📱 Descripción

Esta aplicación permite a los usuarios consultar:
- **Precios por horas** del día actual
- **Precio promedio** de la electricidad
- **Horas más baratas y más caras** del día
- **Gráficos interactivos** de precios
- **Notificaciones** para las mejores tarifas

## 🎯 Motivo del Desarrollo

Este proyecto fue desarrollado como una **migración y modernización** de una aplicación existente que se encontraba en una versión antigua de Flutter. Los principales objetivos fueron:

- ✅ **Actualizar** la aplicación a una versión moderna de Flutter
- ✅ **Corregir problemas** de compatibilidad y dependencias
- ✅ **Mejorar** la arquitectura y estructura del código
- ✅ **Optimizar** el rendimiento y la experiencia de usuario

> **⚠️ Nota Importante**: La API utilizada (`api.preciodelaluz.org`) actualmente **no está funcionando**. Este proyecto se mantiene en GitHub y está disponible en Google Play Store con **fines puramente demostrativos** para mostrar las capacidades técnicas y la calidad del desarrollo.

## 🚀 Tecnologías Utilizadas

- **Flutter** - Framework de desarrollo multiplataforma
- **Dart** - Lenguaje de programación
- **Bloc/Cubit** - Gestión de estado
- **Dio** - Cliente HTTP para consumo de APIs
- **Retrofit** - Generación automática de clientes HTTP
- **Syncfusion Charts** - Gráficos interactivos
- **Flutter Local Notifications** - Sistema de notificaciones

## 📦 Características Técnicas

- ✅ **Arquitectura limpia** con separación de responsabilidades
- ✅ **Gestión de estado** con Bloc pattern
- ✅ **Consumo de APIs REST** con manejo de errores
- ✅ **Interfaz adaptativa** para diferentes tamaños de pantalla
- ✅ **Notificaciones locales** programadas
- ✅ **Gráficos dinámicos** e interactivos
- ✅ **Manejo de timezones** para precios por horas
- ✅ **Build optimizado** para producción con ofuscación

## 🛠️ Instalación y Desarrollo

### Prerrequisitos
- Flutter SDK (versión compatible con el proyecto)
- Android Studio / VS Code
- Git

### Configuración
```bash
# Clonar el repositorio
git clone [URL_DEL_REPOSITORIO]

# Navegar al directorio del proyecto
cd flutter_electricity_price_new

# Instalar dependencias
flutter pub get

# Ejecutar la aplicación en modo debug
flutter run
```

### Build para Producción
```bash
# Android App Bundle (para Google Play Store)
flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info

# APK para instalación directa
flutter build apk --release --obfuscate --split-debug-info=build/debug-info
```

## 📁 Estructura del Proyecto

```
lib/
├── app/
│   ├── custom_widgets/     # Widgets reutilizables
│   ├── home/              # Módulo principal
│   │   ├── cubit/         # Gestión de estado
│   │   ├── models/        # Modelos de datos
│   │   ├── repositories/  # Acceso a datos
│   │   └── widgets/       # Widgets específicos
│   ├── services/          # Servicios (notificaciones, etc.)
│   └── shared/            # Utilidades compartidas
├── env/                   # Configuración de entornos
└── main.dart             # Punto de entrada
```

## 🎨 Capturas de Pantalla

*(Aquí podrías añadir capturas de pantalla de la aplicación)*

## 🔄 Estado del Proyecto

- ✅ **Desarrollo**: Completado
- ✅ **Testing**: Realizado
- ✅ **Build**: Funcional
- ⚠️ **API**: No disponible actualmente
- ✅ **PlayStore**: Publicado con fines demostrativos

## 📄 Licencia

Este proyecto es de código abierto y se distribuye bajo la [Licencia MIT](LICENSE).

## 👨‍💻 Autor

Desarrollado como proyecto de migración y modernización de Flutter.

---

> **Nota**: Este proyecto demuestra las mejores prácticas en desarrollo Flutter, manejo de dependencias, arquitectura de aplicaciones y optimización para producción.
