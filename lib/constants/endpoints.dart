class Endpoints {
  static const uriServidor = "http://192.168.0.104:8081";
  //static const uriServidor = "http://192.168.0.62:8080";

  static const loginEndpoint = "$uriServidor/login";
  static const registerEndpoint = "$uriServidor/register";

  static const profileEndpoint = "$uriServidor/api/users/{id}";
  static const balanceEndpoint = "$uriServidor/api/wallets/{id}";
  static const paymentEndpoint = "$uriServidor/api/payment/{id}";

  static const historyEndpoint = "$uriServidor/api/transactions/users/{id}/transactions-with-items";
  static const productsEndpoint = "$uriServidor/api/products/{id}";
  static const storesEndpoint = "$uriServidor/api/stores";
  static const storeDetailEndpoint = "$uriServidor/api/stores/{id}";
}