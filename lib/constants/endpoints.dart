class Endpoints {
  // static const uriServidor = "http://10.0.2.2:8080";
  static const uriServidor = "http://192.168.3.10:8080";

  static const loginEndpoint = "$uriServidor/login";
  static const registerEndpoint = "$uriServidor/register";

  static const profileEndpoint = "$uriServidor/api/users/{id}";
  static const balanceEndpoint = "$uriServidor/api/wallets/{id}";
  static const paymentEndpoint = "$uriServidor/api/payment/{id}";
  static const rechargeEndpoint = "$uriServidor/api/recharges/{id}";

  static const historyEndpoint = "$uriServidor/api/transactions/by-user";
  static const chatEndpoint = uriServidor; // Socket.IO endpoint para chat
  static const socketEndpoint = uriServidor; // Socket.IO endpoint
  static const chatApiEndpoint = "$uriServidor/api/chats";
  static const productsEndpoint = "$uriServidor/api/products/{id}";
  static const storesEndpoint = "$uriServidor/api/facilities";
  static const storeDetailEndpoint = "$uriServidor/api/facilities/{id}";
  static const storeProductsEndpoint = "$uriServidor/api/facilities/{id}/products";
}