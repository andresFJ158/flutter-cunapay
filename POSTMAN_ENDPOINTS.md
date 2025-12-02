# 📮 Endpoints para Postman - CunaPay API

**URL Base:** `http://localhost:4000`

---

## 🔐 Autenticación (Sin Token)

### 1. Registrar Usuario
```
POST http://localhost:4000/auth/register
Content-Type: application/json

Body (raw JSON):
{
  "email": "usuario@ejemplo.com",
  "password": "contraseña123"
}
```

### 2. Iniciar Sesión
```
POST http://localhost:4000/auth/login
Content-Type: application/json

Body (raw JSON):
{
  "email": "usuario@ejemplo.com",
  "password": "contraseña123"
}

Respuesta esperada:
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": { ... }
}
```

**⚠️ IMPORTANTE:** Copia el `token` de la respuesta y úsalo en los headers de las siguientes peticiones.

---

## 👤 Usuario y Wallet (Requiere Token)

**Header requerido en todas las peticiones:**
```
Authorization: Bearer TU_TOKEN_AQUI
Content-Type: application/json
```

### 3. Obtener Información del Usuario
```
GET http://localhost:4000/api/me
```

### 4. Obtener Wallet
```
GET http://localhost:4000/api/me/wallet

Respuesta esperada:
{
  "address": "Txxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
}
```

### 5. Obtener Balance
```
GET http://localhost:4000/api/me/balance

Respuesta esperada:
{
  "usdt": 100.50,
  "trx": 10.25,
  "available": 50.00,
  "locked_in_staking": 50.50
}
```

---

## 💸 Transacciones (Requiere Token)

### 6. Obtener Transacciones
```
GET http://localhost:4000/api/me/transactions

Query Parameters (opcionales):
- source: "db" | "onchain"
- limit: 10
- status: "pending" | "completed" | "failed"
- direction: "in" | "out"
- fingerprint: "cursor_para_paginacion"
```

**Ejemplo con parámetros:**
```
GET http://localhost:4000/api/me/transactions?limit=10&status=completed
```

### 7. Enviar USDT
```
POST http://localhost:4000/api/me/send
Content-Type: application/json

Body (raw JSON):
{
  "to": "Txxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "amount": "10.5"
}
```

---

## 📈 Staking (Requiere Token)

### 8. Obtener Stakes
```
GET http://localhost:4000/api/me/stakes
```

### 9. Crear Stake
```
POST http://localhost:4000/api/me/stakes
Content-Type: application/json

Body (raw JSON):
{
  "amount_usdt": 100.0,
  "daily_rate_bp": 50
}
```
*Nota: `daily_rate_bp` es la tasa diaria en basis points (50 = 0.5%)*

### 10. Reclamar Intereses de un Stake
```
POST http://localhost:4000/api/me/stakes/{stakeId}/claim

Ejemplo:
POST http://localhost:4000/api/me/stakes/123e4567-e89b-12d3-a456-426614174000/claim
```

### 11. Cerrar un Stake
```
POST http://localhost:4000/api/me/stakes/{stakeId}/close

Ejemplo:
POST http://localhost:4000/api/me/stakes/123e4567-e89b-12d3-a456-426614174000/close
```

---

## 📰 Noticias (Requiere Token)

### 12. Obtener Noticias
```
GET http://localhost:4000/api/news

Query Parameters (opcionales):
- limit: 10
- category: "Economía" | "Política" | etc.
```

**Ejemplo con parámetros:**
```
GET http://localhost:4000/api/news?limit=20&category=Economía
```

### 13. Obtener Noticia por ID
```
GET http://localhost:4000/api/news/{id}

Ejemplo:
GET http://localhost:4000/api/news/123e4567-e89b-12d3-a456-426614174000
```

### 14. Crear Noticia
```
POST http://localhost:4000/api/news
Content-Type: application/json

Body (raw JSON):
{
  "title": "Título de la noticia",
  "category": "Economía",
  "link": "https://ejemplo.com/noticia",
  "image": "https://ejemplo.com/imagen.jpg",
  "economicImpact": "Esta noticia afecta el mercado..."
}
```

### 15. Actualizar Noticia
```
PUT http://localhost:4000/api/news/{id}
Content-Type: application/json

Body (raw JSON) - Solo incluye los campos que quieres actualizar:
{
  "title": "Nuevo título",
  "category": "Política"
}
```

### 16. Eliminar Noticia
```
DELETE http://localhost:4000/api/news/{id}

Ejemplo:
DELETE http://localhost:4000/api/news/123e4567-e89b-12d3-a456-426614174000
```

### 17. Obtener Categorías de Noticias
```
GET http://localhost:4000/api/news/categories

Respuesta esperada:
{
  "categories": ["Economía", "Política", "Tecnología", ...]
}
```

---

## 💱 Tipo de Cambio (NUEVO - Requiere Token)

### 18. Obtener Tipo de Cambio del Dólar
```
GET http://localhost:4000/api/exchange-rate

Respuesta esperada (formato 1):
{
  "rate": 7.0
}

O formato alternativo:
{
  "price": 7.0
}

O:
{
  "exchangeRate": 7.0
}

O:
{
  "usdToBob": 7.0
}

O:
{
  "value": 7.0
}

O simplemente un número:
7.0
```

**⚠️ IMPORTANTE:** El endpoint debe retornar el precio del dólar en bolivianos (Bs/USDT). La app busca el valor en cualquiera de estos campos: `rate`, `price`, `exchangeRate`, `usdToBob`, `value`, o como número directo.

---

## 📋 Resumen de Headers

### Para peticiones SIN autenticación:
```
Content-Type: application/json
```

### Para peticiones CON autenticación:
```
Authorization: Bearer TU_TOKEN_AQUI
Content-Type: application/json
```

---

## 🔧 Configuración en Postman

1. **Crear una Variable de Entorno:**
   - Ve a "Environments" → "Create Environment"
   - Agrega variable: `base_url` = `http://localhost:4000`
   - Agrega variable: `token` = (déjala vacía, se llenará después del login)

2. **Usar la variable en las URLs:**
   - En lugar de escribir `http://localhost:4000`, usa: `{{base_url}}`
   - Para el token: `{{token}}`

3. **Script de Login automático (opcional):**
   En la petición de Login, en la pestaña "Tests", agrega:
   ```javascript
   if (pm.response.code === 200) {
       var jsonData = pm.response.json();
       pm.environment.set("token", jsonData.token);
   }
   ```

---

## ✅ Checklist de Endpoints

- [x] POST /auth/register
- [x] POST /auth/login
- [x] GET /api/me
- [x] GET /api/me/wallet
- [x] GET /api/me/balance
- [x] GET /api/me/transactions
- [x] POST /api/me/send
- [x] GET /api/me/stakes
- [x] POST /api/me/stakes
- [x] POST /api/me/stakes/{id}/claim
- [x] POST /api/me/stakes/{id}/close
- [x] GET /api/news
- [x] GET /api/news/{id}
- [x] POST /api/news
- [x] PUT /api/news/{id}
- [x] DELETE /api/news/{id}
- [x] GET /api/news/categories
- [x] GET /api/exchange-rate ⭐ **NUEVO**

---

## 🚨 Notas Importantes

1. **CORS:** Si pruebas desde Postman Web, asegúrate de que el backend tenga CORS habilitado.

2. **Token:** El token expira después de cierto tiempo. Si recibes error 401, vuelve a hacer login.

3. **Formato de Respuesta:** Algunos endpoints pueden retornar diferentes formatos. La app está preparada para manejar variaciones.

4. **Tipo de Cambio:** El endpoint `/api/exchange-rate` es **nuevo** y debe implementarse en el backend si no existe aún.

