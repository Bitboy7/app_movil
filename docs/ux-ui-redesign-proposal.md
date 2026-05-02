# Bibu — Propuesta de Rediseño UX/UI

> **Versión:** 1.0 | **Fecha:** Mayo 2026 | **Autor:** Diagnóstico de código real

---

## Índice

1. [Diagnóstico de UX/UI](#1-diagnóstico-de-uxui)
2. [Errores principales](#2-errores-principales)
3. [Propuesta de rediseño visual](#3-propuesta-de-rediseño-visual)
   - [3a. Uso de color](#3a-uso-de-color)
   - [3b. Uso de gradiente](#3b-uso-de-gradiente)
   - [3c. Tipografía](#3c-tipografía)
   - [3d. Cards](#3d-cards)
   - [3e. Botones](#3e-botones)
   - [3f. Inputs](#3f-inputs)
   - [3g. Navegación](#3g-navegación)
   - [3h. Barras de progreso](#3h-barras-de-progreso)
   - [3i. Badges y métricas](#3i-badges-y-métricas)
4. [Motion Design](#4-motion-design)
   - [4a. Sistema de duraciones](#4a-sistema-de-duraciones)
   - [4b. Sistema de easing](#4b-sistema-de-easing)
   - [4c. Qué animar y cómo](#4c-qué-animar-y-cómo)
   - [4d. Qué NO animar](#4d-qué-no-animar)
   - [4e. Técnicas Flutter por contexto](#4e-técnicas-flutter-por-contexto)
5. [Sistema de comportamiento de la mascota](#5-sistema-de-comportamiento-de-la-mascota)
   - [5a. Estados emocionales](#5a-estados-emocionales)
   - [5b. Eventos que disparan cambios](#5b-eventos-que-disparan-cambios)
   - [5c. Reacciones al completar tarea](#5c-reacciones-al-completar-tarea)
   - [5d. Evolución por niveles](#5d-evolución-por-niveles)
   - [5e. Interacción por pantalla](#5e-interacción-por-pantalla)
6. [Microinteracciones concretas](#6-microinteracciones-concretas)
   - [6a. Completar tarea](#6a-completar-tarea)
   - [6b. Desbloquear accesorio](#6b-desbloquear-accesorio)
   - [6c. Subir nivel](#6c-subir-nivel)
   - [6d. Aumentar racha](#6d-aumentar-racha)
   - [6e. Sumar XP](#6e-sumar-xp)
   - [6f. Login exitoso](#6f-login-exitoso)
   - [6g. Error de validación](#6g-error-de-validación)
7. [Priorización](#7-priorización)
   - [Quick Wins (1-3 días)](#quick-wins-1-3-días)
   - [Mejoras Medianas (3-7 días)](#mejoras-medianas-3-7-días)
   - [Mejoras Premium (1-2 semanas)](#mejoras-premium-1-2-semanas)
8. [Pantalla Home ideal](#8-pantalla-home-ideal)

---

## 1. Diagnóstico de UX/UI

### Lo que está bien

| Aspecto | Detalle |
|---|---|
| Paleta coherente | `#7C5CFC` (primario) + `#FF6B8A` (secundario) + `#36D6E7` (acento) |
| Arquitectura | Feature-based con Domain/Data/Presentation. Riverpod consistente |
| Temas claro/oscuro | `ThemeData` completo con `ColorScheme.light` / `ColorScheme.dark` |
| Bottom nav | FAB flotante con `extendBody: true` y `AnimatedContainer` en tabs |
| Animaciones | Uso extensivo de `flutter_animate` en todas las pantallas |
| PetWidget | Stack por capas con animación de respiración continua |

### Lo que necesita mejora

| Problema | Archivo(s) | Impacto |
|---|---|---|
| **10 border-radius diferentes** (10,12,14,16,18,20,24,28,30,36) | Toda la app | Inconsistencia visual |
| **8 duraciones de animación** sin sistema unificado | Toda la app | Motion caótico |
| **La mascota es emoji**, no Lottie | `pet_widget.dart:81` | Se ve barato, no transmite personalidad |
| **La mascota no reacciona** al progreso del usuario | `home_page.dart:66-74` | El diferenciador del producto es decorativo |
| **Sin feedback háptico** en ninguna interacción | Toda la app | Completar tareas se siente vacío |
| **Header de home compite con task cards** | `home_page.dart:100-177` | Gradiente morado→rosa domina todo |
| **Emojis y Material Icons mezclados** | `pet_widget.dart:81` vs `task_card.dart:134` | Inconsistencia de identidad |
| **Sin `ThemeExtension` ni design tokens** | `app_theme.dart` | Valores inline, difícil mantenimiento |
| **Barra de progreso estática** | `home_page.dart:159-167` | `LinearProgressIndicator` sin animación |
| **`star.json` existe pero no se usa** | `assets/lottie/star.json` | Recurso de celebración desperdiciado |
| **Contraste insuficiente en dark mode** | `app_theme.dart:152` | Ratio ~4.2:1 (mínimo recomendado 4.5:1) |
| **Dos sistemas de animación** | `AnimationController` en login vs `flutter_animate` en home | Sin cohesión |

---

## 2. Errores principales

### Error #1 — La mascota es decorativa, no reactiva
Completar una tarea solo cambia un checkbox en `task_card.dart`. La mascota no salta, no celebra, no cambia su expresión. El núcleo del producto (la mascota que progresa) no existe como experiencia.

### Error #2 — Sin recompensa inmediata
No hay animación de XP volando, ni confetti, ni badge emergente al completar una tarea. El usuario realiza la acción y no ve consecuencia visual clara.

### Error #3 — Jerarquía visual plana
El header (`home_page.dart:100-177`) con gradiente primario→secundario ocupa ~180px con colores saturados. Las task cards compiten por atención. Todo grita al mismo volumen. La regla es: **1 elemento domina, 2 apoyan, el resto descansa**.

### Error #4 — Inconsistencia de tokens
10 variaciones de border-radius, 8 duraciones de animación, mezcla de emoji e iconos. Una app nativa de calidad usa máximo 4-5 tokens por categoría.

### Error #5 — Sin sistema de motion unificado
`AnimationController` en `login_screen.dart`, `flutter_animate` en `home_page.dart`, `AnimatedContainer` en `task_card.dart`, `TweenAnimationBuilder` en `stats_page.dart`. Cada pantalla usa técnicas distintas. Debe haber UN solo sistema de reglas.

### Error #6 — Dark mode con contraste bajo
`textSecondaryDark = Color(0xFF9CA3AF)` sobre `backgroundDark = Color(0xFF0F0F1A)` tiene un ratio de contraste de ~4.2:1. WCAG AA requiere 4.5:1.

### Error #7 — Home y Pet screen visualmente indistinguibles
Ambas pantallas usan el MISMO gradiente morado→rosa como card destacada. `pet_screen.dart` y `home_page.dart` son visualmente clones en su elemento principal.

### Error #8 — Sin onboarding contextual
Un usuario nuevo no sabe que la mascota evoluciona, que los accesorios existen, o qué significan las métricas. No hay tooltips ni coach marks.

---

## 3. Propuesta de rediseño visual

### 3a. Uso de color

```dart
// Tokens de color — reemplazar AppColors actual
abstract class AppColors {
  // Marca (se mantienen)
  static const primary       = Color(0xFF7C5CFC);
  static const primaryLight  = Color(0xFFB19DFF);
  static const primaryDark   = Color(0xFF5A3FCF);
  static const secondary     = Color(0xFFFF6B8A);
  static const secondaryLight= Color(0xFFFFA3B5);
  static const accent        = Color(0xFF36D6E7);
  static const accentLight   = Color(0xFF7DE8F3);

  // Semánticos
  static const success       = Color(0xFF4ADE80);
  static const warning       = Color(0xFFFB923C);
  static const error         = Color(0xFFF87171);

  // Mascota (NUEVOS)
  static const petHappy      = Color(0xFFFFD166);
  static const petSad        = Color(0xFF8B9DC3);
  static const petNeutral    = Color(0xFFB8B5E0);

  // Superficies (REEMPLAZAN los actuales)
  static const bgLight       = Color(0xFFF6F4FF);  // off-white con toque primario
  static const bgDark        = Color(0xFF0D0C1A);  // near-black con toque primario
  static const surfaceLight  = Color(0xFFFFFFFF);
  static const surfaceDark   = Color(0xFF1A1A2E);
  static const cardLight     = Color(0xFFFFFFFF);
  static const cardDark      = Color(0xFF242442);

  // Texto
  static const textPrimaryLight   = Color(0xFF1A1A2E);
  static const textSecondaryLight = Color(0xFF6B7280);
  static const textTertiaryLight  = Color(0xFF9CA3AF);
  static const textPrimaryDark    = Color(0xFFF1F1F6);
  static const textSecondaryDark  = Color(0xFFB0B7C3);  // AUMENTADO de #9CA3AF
  static const textTertiaryDark   = Color(0xFF7A8090);  // AUMENTADO de #6B7280
}
```

**Reglas:**
- El secundario (#FF6B8A) NO va en gradientes de fondo. Solo en badges, notificaciones y celebración.
- Los colores de mascota (`petHappy`, `petSad`, `petNeutral`) definen el tono emocional del PetWidget.
- Máximo 3 colores saturados visibles simultáneamente en una pantalla.

### 3b. Uso de gradiente

| Contexto | Gradiente | Intensidad |
|---|---|---|
| Splash screen | `primaryDark → primary → secondary` | Completo (marca) |
| Header home (card mascota) | `primary@5% → secondary@3%` | Casi imperceptible |
| Celebración (nivel up) | `primary → secondary` | Overlay temporal |
| Botones CTA | Sin gradiente, color sólido | — |
| Cards de contenido | Sin gradiente, fondo sólido + sombra | — |

**Regla de oro:** El gradiente es para la marca (splash) y la celebración (nivel up), nunca para el contenido diario.

### 3c. Tipografía

Mantener **Nunito** (correcta: redonda, amigable). Jerarquía fija:

```dart
abstract class AppTextStyles {
  // Rol          Size  Weight  LetterSpacing
  // hero         48    w800    -0.5       → Nivel, racha grande
  // displayLarge 32    w800    0          → Título de pantalla
  // displayMedium 24   w700    0          → Subtítulo sección
  // titleLarge   18    w700    0          → Card title
  // titleMedium  16    w600    0          → Subtitle, label botón
  // bodyLarge    16    w500    0          → Texto descriptivo
  // bodyMedium   14    w500    0          → Texto secundario
  // bodySmall    12    w500    0          → Metadata, caption
  // labelLarge   14    w700    0          → Botones, chips
  // labelSmall   11    w600    0.5        → Badges, pills
}
```

**Regla:** Máximo 3 tamaños de fuente diferentes visibles en una misma pantalla.

### 3d. Cards

```dart
// Token de border-radius — REEMPLAZA los 10 valores dispersos
abstract class AppRadius {
  static const sm   = 8.0;   // Chips, badges pequeños
  static const md   = 12.0;  // Inputs, contenedores chicos
  static const lg   = 16.0;  // Botones, cards secundarias
  static const xl   = 20.0;  // Cards principales
  static const full = 999.0; // Pills, badges circulares
}
```

**Card principal** (task cards, stats cards, settings cards):
- `BorderRadius.circular(AppRadius.xl)`, fondo `surface`
- Sin gradiente
- Borde: `1px` con `onSurface.withValues(alpha: 0.08)`
- Sombra: `blur: 8, offset: (0,4), opacity: 0.06`
- Padding: `EdgeInsets.symmetric(horizontal: 20, vertical: 16)`

**Card destacada** (solo header de home con mascota):
- `BorderRadius.circular(28)`, gradiente ultra-sutil (`primary@5% → secondary@3%`)
- Sombra: `blur: 16, offset: (0,8), opacity: 0.10`
- Sin borde

### 3e. Botones

```
Tipo         Fondo            Borde             Label         Height  Radius
──────────────────────────────────────────────────────────────────────────
Primario     primary          none              white w700    56      lg(16)
Secundario   transparent      primary 1.5px     primary w600  56      lg(16)
Peligro      transparent      error 1.5px       error w600    56      lg(16)
Ghost        transparent      none              primary@70%   48      —
FAB          primary          none              white         56      circle
```

**Reglas:**
- Altura mínima 52px (56px recomendado) para touch target accesible.
- Los botones NUNCA usan gradiente, excepto el CTA principal del onboarding.
- `AnimatedScale` 1.0→0.96 en press (150ms, easeOut).

### 3f. Inputs

- `BorderRadius.circular(AppRadius.md)`, altura 52px
- Fondo: `surface` con 50% opacidad
- Borde reposo: `onSurface@12%`, 1px
- Borde foco: `primary`, 2px, con glow sutil (`blur: 4`)
- Borde error: `error`, 2px + animación de shake
- Label flotante animado (no placeholder estático)
- Helper text animado con fade

### 3g. Navegación

Mejoras sobre el `AppBottomNav` actual (que ya está bien ejecutado):

- **Badge en ícono de mascota**: dot rojo cuando hay accesorios desbloqueables.
- **FAB con pulso**: `scale 1.0↔1.06` loop (1200ms) cuando hay tareas pendientes.
- **Transición entre tabs**: `FadeTransition` de 200ms en lugar de `NoTransitionPage`.
- **Swipe back**: mantener en ambas plataformas.

### 3h. Barras de progreso

Reemplazar `LinearProgressIndicator` estático por esto en TODA la app:

```dart
TweenAnimationBuilder<double>(
  tween: Tween(begin: 0, end: progress),
  duration: AppDuration.slow,       // 600ms
  curve: Curves.easeOutCubic,
  builder: (context, value, _) => ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: LinearProgressIndicator(
      value: value,
      minHeight: 8,
      backgroundColor: color.withValues(alpha: 0.12),
      valueColor: AlwaysStoppedAnimation(color),
    ),
  ),
)
```

### 3i. Badges y métricas

```
Tipo            Forma    Fondo              Texto
────────────────────────────────────────────────────
Nivel           Pill     primary@12%        primary w700
Racha           Pill     warning@12%        warning w700 + 🔥
Monedas         Pill     amber@12%          amber w700 + 🪙
XP ganado hoy   Pill     primary@8%         primary w600
Completadas     Chip     success@10%        success w600 + ✅
```

Todas las métricas numéricas usan `TweenAnimationBuilder` para animar el contador al cambiar.

---

## 4. Motion Design

### 4a. Sistema de duraciones

```dart
abstract class AppDuration {
  static const instant  = Duration.zero;                      // 0ms
  static const micro    = Duration(milliseconds: 150);        // press, ripple
  static const quick    = Duration(milliseconds: 250);        // fade, íconos
  static const standard = Duration(milliseconds: 350);        // navegación, cards
  static const slow     = Duration(milliseconds: 500);        // énfasis
  static const dramatic = Duration(milliseconds: 800);        // nivel up
}
```

### 4b. Sistema de easing

```dart
abstract class AppEasing {
  // Reglas fijas, no elegir arbitrariamente:
  static const appear   = Curves.easeOut;       // Elementos que APARECEN
  static const disappear= Curves.easeIn;         // Elementos que DESAPARECEN
  static const loop     = Curves.easeInOut;      // Loops continuos
  static const pop      = Curves.easeOutBack;    // "pop" (check, badge)
  static const counter  = Curves.easeOutCubic;   // Barras, contadores
}
```

### 4c. Qué animar y cómo

| Evento | Técnica | Duración | Easing |
|---|---|---|---|
| Elementos en scroll | `flutter_animate` `.fadeIn().slideY(0.04)` stagger 60ms | `standard` | `appear` |
| Checkbox completado | `TweenAnimationBuilder<double>` scale 0→1.25→1.0 | `standard` | `pop` |
| Card completada | `AnimatedContainer` cambia color/sombra/borde | `quick` | `appear` |
| XP volando | `AnimatedPositioned` + fade, badge sube 40px | `slow` | `counter` |
| Subir nivel overlay | Lottie + `AnimatedOpacity` + `Transform.scale` | `dramatic` | `pop` |
| Cambiar tab | `FadeTransition` (ambos: fade out/in) | `quick` | `appear` |
| Abrir modal | `.slideY(0.3).fadeIn()` | `standard` | `counter` |
| Botón press | `AnimatedScale` 1.0→0.96 | `micro` | `appear` |
| Input error | `Transform.translate` + sin(4 oscilaciones) | `quick` | — |
| Mascota idle | `.scale()` loop 1.0↔1.04 (2000ms) | — | `loop` |
| Mascota reacción | `.moveY()` jump 0→-10→0 (300ms) | `quick` | `pop` |

### 4d. Qué NO animar

- **Cambio de tema**: instantáneo (rompe la inmersión animarlo).
- **Transiciones entre tabs del shell**: fade-through sutil, NUNCA slide horizontal.
- **Texto que cambia de contenido**: solo fade con `AnimatedSwitcher`, no scale ni slide.
- **El FAB**: no animar su posición, solo escala en press.
- **Listas al reordenarse**: solo si usas `AnimatedList`, nunca animar rebuilds normales.

### 4e. Técnicas Flutter por contexto

| Contexto | Widget/Técnica |
|---|---|
| Animaciones de entrada en listas | `flutter_animate` (`.fadeIn().slideY()`) |
| Barras de progreso y contadores | `TweenAnimationBuilder<double>` |
| Cambios de estado visual | `AnimatedContainer` |
| Transiciones de contenido | `AnimatedSwitcher` |
| Loops continuos | `AnimationController` + `Repeat` |
| Momentos emocionales | **Lottie** (`Lottie.asset()`) |
| Feedback táctil | `HapticFeedback.lightImpact()` / `.mediumImpact()` / `.heavyImpact()` |
| Shake de error | `AnimationController` con `Transform.translate` + `sin` |

---

## 5. Sistema de comportamiento de la mascota

### 5a. Estados emocionales

| Estado | Expresión | Animación | Color de fondo |
|---|---|---|---|
| `sleeping` | Ojos cerrados, Zzz | Respiración muy lenta (3000ms) | #2D2B55 |
| `sad` | Expresión caída, lágrima ocasional | Movimiento mínimo, cabeza baja | #8B9DC3@20% |
| `neutral` | Mirada tranquila | Respiración normal (2000ms) | #B8B5E0@20% |
| `happy` | Sonrisa, ojos brillantes | Bounce sutil, movimiento fluido | #FFD166@20% |
| `excited` | Saltos, estrellas | Jump animado, partículas | #FFD166@40% |
| `proud` | Pecho inflado, corona | Pose heroica, brillo | #FFD166@30% + glow |

### 5b. Eventos que disparan cambios

| Evento | Estado resultante | Duración | Reversible |
|---|---|---|---|
| Completar 1 tarea | `neutral` → `excited` (2s) → `happy` | 2s + permanente | Sí, vuelve a neutral |
| Completar TODAS las tareas | `proud` | Hasta medianoche | Reset diario |
| 3h+ sin completar nada | `sad` progresivo | Gradual | Sí, completa tarea |
| Subir de nivel | `excited` + overlay celebración | 3.5s | Vuelve a happy |
| Perder racha | `sad` | Hasta completar tarea | Sí |
| Racha ≥ 7 días | `proud` | Todo el día | — |
| Login exitoso (1er del día) | `happy` (saludo) | 2s | Vuelve a neutral |
| 24h+ sin abrir app | `sleeping` | Hasta abrir app | Sí, al abrir |
| Volver tras 6h+ | `happy` (reencuentro) | 3s | Vuelve a neutral |

### 5c. Reacciones al completar tarea

```
Secuencia completa (en orden):
1. HapticFeedback.lightImpact()                           ← instantáneo
2. Mascota: mini-jump (translateY: 0→-10→0, 300ms)       ← pop easing
3. Mascota: expresión cambia a happy/excited               ← 150ms crossfade
4. Badge "+15 XP ⭐" emerge del checkbox y vuela arriba    ← 600ms, counter easing
5. Barra de progreso animada en header                     ← 600ms, counter easing
6. Si es la ÚLTIMA tarea: Lottie star.json + mascota proud ← 800ms
```

### 5d. Evolución por niveles

| Rango | Apariencia | Tamaño | Idle animation | Accesorios |
|---|---|---|---|---|
| 1-2 | Bebé | 0.8x | Respiración simple | 0 |
| 3-4 | Crecido | 0.9x | Respiración + parpadeo | Sugerencia visual |
| 5-9 | Joven | 1.0x | Respiración + bounce ocasional | 2-3 disponibles |
| 10-14 | Adulto | 1.1x | Idle animado con partículas | 4-6 disponibles |
| 15+ | Legendario | 1.2x | Idle premium + aura | Todos + exclusivos |

- Cada **5 niveles**: mini-evolución (animación de transformación, 2s).
- Cada **10 niveles**: gran evolución (Lottie + pantalla completa, 4s).

### 5e. Interacción por pantalla

| Pantalla | Mascota | Interacción |
|---|---|---|
| **Login** | Dormida, detrás del formulario | Despierta al login exitoso |
| **Home** | 96px en header, foco visual | Reacciona en tiempo real al progreso |
| **Pet Screen** | 220px centro, interactiva | Tap = acariciar, long press = truco, swipe = girar |
| **Stats** | 48px miniatura junto a logros | Expresión de celebración |

---

## 6. Microinteracciones concretas

### 6a. Completar tarea

```
Flujo completo:

1. Usuario hace tap en checkbox
2. HapticFeedback.lightImpact()
3. Checkbox: fondo transparent → task.category.color (300ms, easeOut)
   + scale: 1.0 → 1.25 → 1.0 (350ms, easeOutBack)
   + ícono check fadeIn (200ms)
4. Task card: AnimatedContainer → estado completado
   - color → atenuado con opacidad 0.4
   - título → lineThrough + opacidad 0.6
   - sombra → eliminada
   - borde → color de categoría al 30% (250ms, easeOut)
5. Badge XP: emerge del checkbox "+15 XP ⭐"
   - AnimatedPositioned: bottom 0 → -40
   - AnimatedOpacity: 1.0 → 0.0
   - 600ms total, easeOutCubic
6. Mascota en header:
   - PetWidget: .moveY(0→-10→0), 300ms, easeOutBack
   - Expresión: crossfade a happy (250ms)
7. Barra progreso header: TweenAnimationBuilder 0→nuevo valor, 600ms
8. SI es la última tarea del día:
   - Lottie star.json overlay, 2000ms, auto-dismiss
   - Mascota expresión proud + pose heroica
   - HapticFeedback.mediumImpact()
```

### 6b. Desbloquear accesorio

```
1. En pet_screen.dart, card del accesorio:
   - Shimmer: gradient animado recorre la card
   - Ícono candado 🔒 → fadeOut (150ms)
   - Ícono accesorio 👑 → scaleIn 0→1.0 (350ms, easeOutBack)
2. Toast en bottom: "¡Desbloqueaste: Corona 👑!"
   - slideUp + fadeIn (350ms)
3. Mascota recibe accesorio automáticamente
   - Accesorio cae desde arriba con bounce
4. HapticFeedback.mediumImpact()
```

### 6c. Subir nivel

```
1. Pantalla completa overlay (AnimatedOpacity 0→1, 300ms):
   - Fondo: Colors.black54 con blur
   - Mascota grande al centro (280px), animación excited
2. Texto "¡NIVEL 5!":
   - AnimatedScale 0→1.2→1.0, easeOutBack, 600ms
   - FadeIn, 400ms
3. Barra XP animada 0→1.0, 800ms, easeOutCubic
4. Partículas: Lottie star.json alrededor de la mascota
5. HapticFeedback.heavyImpact() al aparecer
6. Auto-dismiss: 3.5s o tap para cerrar
7. Al cerrar: mascota vuelve con nueva apariencia si evolucionó
```

### 6d. Aumentar racha

```
1. Badge en home: número con TweenAnimationBuilder (anterior→nuevo, 400ms)
2. Si racha alcanza 3: aparece 🔥 con scale + fade (300ms)
3. Si racha alcanza 7: 🔥🔥🔥 animación intensa + badge gradiente cálido
4. Si racha alcanza 30: overlay celebración (similar a nivel up)
5. Toast solo en hitos (3, 7, 14, 30, 100):
   "¡Racha de 7 días! 🔥 Increíble consistencia"
```

### 6e. Sumar XP

```
1. Número XP en header/stats: TweenAnimationBuilder (anterior→nuevo, 400ms)
2. Barra de progreso sincronizada con el contador
3. Si se alcanza 100%: dispara animación de subir nivel (6c)
4. Estrella ⭐ vuela desde task card hasta barra de XP del header:
   - AnimatedPositioned + AnimatedOpacity, 500ms, easeOutCubic
```

### 6f. Login exitoso

```
1. Botón: spinner → AnimatedSwitcher con check (scale+rotate, 350ms)
2. HapticFeedback.mediumImpact()
3. Mascota dormida: despierta (scaleY 0.8→1.0, easeOutBack)
   - Expresión: sleeping → happy (crossfade, 400ms)
4. Fondo gradiente: intensifica colores brevemente (500ms)
5. Transición a home:
   - Login: fadeOut 250ms
   - Home: fadeIn + slideY(0.05), 400ms, easeOut
```

### 6g. Error de validación

```
1. Campo con error:
   - Borde: onSurface@12% → error, 200ms
   - Transform.translate con sin(4 oscilaciones de ±6px), 300ms
2. Helper text rojo: fadeIn + slideY(0→4), 200ms
3. Ícono error ⚠️ en trailing del input: fadeIn + scale, 200ms
4. Si es login fallido:
   - Botón: mismo shake horizontal
   - Toast: "Email o contraseña incorrectos" con error color
   - Mascota: expresión confused/sad por 2s
```

---

## 7. Priorización

### Quick Wins (1-3 días)

| # | Acción | Archivos afectados | Esfuerzo |
|---|---|---|---|
| 1 | Crear `AppRadius` y reemplazar 10 border-radius | Toda la app | 2h |
| 2 | Crear `AppDuration` + `AppEasing` y unificar animaciones | Toda la app | 2h |
| 3 | Agregar `HapticFeedback` al completar tarea | `home_page.dart:66-74` | 15min |
| 4 | Animación de check (easeOutBack) al toggle | `task_card.dart:94-116` | 30min |
| 5 | Badge de XP flotante al completar | `home_page.dart:66-74` | 1h |
| 6 | Barra de progreso animada (TweenAnimationBuilder) | `home_page.dart:159-167` | 30min |
| 7 | Reducir intensidad del gradiente del header | `home_page.dart:104-108` | 5min |
| 8 | Mascota reacciona (jump) al completar tarea | `pet_widget.dart`, `home_page.dart` | 1h |
| 9 | Input shake en validación de login | `login_screen.dart` | 1h |
| 10 | Ajustar contraste dark mode (textSecondaryDark) | `app_theme.dart:152` | 2min |

### Mejoras Medianas (3-7 días)

| # | Acción | Esfuerzo |
|---|---|---|
| 11 | Reemplazar emoji de mascota por Lottie con estados | 2-3 días |
| 12 | Sistema de estados emocionales (5 estados) | 1 día |
| 13 | Overlay de subir nivel con Lottie | 1 día |
| 14 | Animación de desbloquear accesorio (shimmer + candado) | 1 día |
| 15 | Usar `star.json` para celebración al completar todo | 2h |
| 16 | Contadores animados (XP, monedas, racha) con `TweenAnimationBuilder` | 1 día |
| 17 | Rediseñar header de home: card de mascota como foco | 1 día |
| 18 | Crear `ThemeExtension` para tokens de diseño | 3h |
| 19 | Coach marks para primer uso (tooltips en home/pet/stats) | 1 día |

### Mejoras Premium (1-2 semanas)

| # | Acción |
|---|---|
| 20 | Mascota interactiva: tap (acariciar), long press (truco), swipe (girar) |
| 21 | Sistema de evolución visual con 4 etapas por tipo de mascota (Lottie) |
| 22 | Háptica personalizada: light (tarea), medium (accesorio), heavy (nivel) |
| 23 | Sound design opcional (efectos sutiles para interacciones clave) |
| 24 | Widget de mascota en pantalla de inicio del teléfono |
| 25 | Daily login streak con animación de mascota saludando |
| 26 | Temas de temporada (Halloween, Navidad) para la mascota |
| 27 | Notificaciones push con la cara de la mascota |

---

## 8. Pantalla Home ideal

```
┌──────────────────────────────────────────┐
│  [🐣]  Viernes, 1 de mayo     🪙 245   │  ← AppBar minimalista
├──────────────────────────────────────────┤
│                                          │
│  ┌──────────────────────────────────┐    │  ← Card de Mascota (180px)
│  │                                  │    │     gradiente ultra-sutil
│  │         ┌──────────┐            │    │     primary@5%→secondary@3%
│  │         │  LOTTIE  │            │    │
│  │         │ MASCOTA  │            │    │  ← Mascota animada con
│  │         │ 160x160  │            │    │     Lottie, estado emocional
│  │         │ (happy)  │            │    │     actual visible
│  │         └──────────┘            │    │
│  │                                  │    │
│  │       Bibu    ┌──────────┐      │    │  ← Nombre + badge nivel
│  │               │  Nv. 5   │      │    │
│  │               └──────────┘      │    │
│  │  ═══════════════════════        │    │  ← Barra XP animada
│  │  234 / 450 XP                   │    │     (siempre TweenAnimation)
│  └──────────────────────────────────┘    │
│                                          │
│  ✅ 3/6    ⭐ 120 XP    🔥 5 días       │  ← Row de métricas rápidas
│  ┌────────┐┌──────────┐┌────────────┐  │     pills con íconos
│  │ pill   ││  pill    ││   pill     │  │
│  └────────┘└──────────┘└────────────┘  │
│                                          │
│  Tareas de hoy                    [+]  │  ← Sección título + botón
│                                          │
│  ┌──────────────────────────────────┐    │  ← Task cards (no completadas
│  │ ◯  [❤️]  Meditar 10 min    ⭐15  │    │     primero, stagger 60ms)
│  │          08:00 AM               │    │
│  └──────────────────────────────────┘    │
│  ┌──────────────────────────────────┐    │
│  │ ◯  [📚]  Leer 30 min       ⭐20  │    │
│  │          09:00 AM               │    │
│  └──────────────────────────────────┘    │
│  ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐    │  ← Tarea completada:
│  │ ✓  [💪]  Ejercicio 45 min  ⭐30  │    │     opacidad reducida,
│  │          07:00 AM               │    │     tachado, sin sombra
│  └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘    │
│                                          │
│              [     +     ]              │  ← FAB central (pulso si
│                                          │     hay pendientes)
│  ┌──────────┐ ┌────┐ ┌────┐ ┌──────┐  │
│  │  Inicio  │ │Masc│ │Stat│ │Ajust│  │  ← Bottom nav flotante
│  └──────────┘ └────┘ └────┘ └──────┘  │
└──────────────────────────────────────────┘

COLORES VISIBLES EN PANTALLA:
- primary (#7C5CFC): checkboxes, barra progreso, iconos seleccionados, FAB
- success (#4ADE80): tareas completadas, métrica "Completadas"
- warning (#FB923C): pill de racha
- surface: cards, fondo de pills
- texto: onSurface, onSurface@60%, onSurface@40%
- MÁXIMO 3 colores saturados simultáneos
```

### Reglas definitivas del home ideal

1. La mascota es lo PRIMERO que ves, no un ícono de 64px en una esquina.
2. El gradiente del header actual DESAPARECE. Se reemplaza por una card con gradiente casi imperceptible (5%→3%).
3. Task cards limpias: fondo sólido + borde sutil + sombra mínima. Sin gradiente.
4. Jerarquía vertical: MASCOTA → MÉTRICAS → TAREAS.
5. Fondo scaffold: `#F6F4FF` (light) / `#0D0C1A` (dark) — off-white/purple sutil.
6. Nunca más de 3 colores fuertes en pantalla.
7. Todo lo numérico se anima (contadores, barras, badges).
8. La mascota reacciona en tiempo real — si no, es decoración.
9. `HapticFeedback` en cada acción significativa.
10. Las tareas completadas se recolocan al final con animación, no se quedan mezcladas.

---

## Registro de implementación

| Fase | Fecha inicio | Fecha fin | Estado |
|---|---|---|---|
| Quick Wins 1-10 | — | — | Pendiente |
| Medianas 11-19 | — | — | Pendiente |
| Premium 20-27 | — | — | Pendiente |
