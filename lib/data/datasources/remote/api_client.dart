import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'api_client.g.dart';

/// Retrofit API Client for Talk API
@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  // ============ Authentication ============

  @POST('/auth/phone_verifications')
  Future<HttpResponse<dynamic>> requestVerificationCode(@Body() Map<String, dynamic> body);

  @POST('/auth/phone_verifications/verify')
  Future<HttpResponse<dynamic>> verifyCode(@Body() Map<String, dynamic> body);

  @POST('/auth/registrations')
  Future<HttpResponse<dynamic>> register(@Body() Map<String, dynamic> body);

  @POST('/auth/sessions')
  Future<HttpResponse<dynamic>> login(@Body() Map<String, dynamic> body);

  @DELETE('/auth/sessions')
  Future<HttpResponse<dynamic>> logout();

  @GET('/auth/sessions/current')
  Future<HttpResponse<dynamic>> getCurrentSession();

  // ============ Legacy Auth (backward compatibility) ============

  @POST('/auth/request_code')
  Future<HttpResponse<dynamic>> requestCodeLegacy(@Body() Map<String, dynamic> body);

  @POST('/auth/verify_code')
  Future<HttpResponse<dynamic>> verifyCodeLegacy(@Body() Map<String, dynamic> body);

  @POST('/auth/register')
  Future<HttpResponse<dynamic>> registerLegacy(@Body() Map<String, dynamic> body);

  @POST('/auth/login')
  Future<HttpResponse<dynamic>> loginLegacy(@Body() Map<String, dynamic> body);

  // ============ Users ============

  @GET('/users/me')
  Future<HttpResponse<dynamic>> getMe();

  @PATCH('/users/me')
  Future<HttpResponse<dynamic>> updateMe(@Body() Map<String, dynamic> body);

  @GET('/users/{id}')
  Future<HttpResponse<dynamic>> getUserById(@Path() int id);

  @POST('/users/{id}/block')
  Future<HttpResponse<dynamic>> blockUser(@Path() int id);

  @POST('/users/{id}/unblock')
  Future<HttpResponse<dynamic>> unblockUser(@Path() int id);

  @GET('/users/blocks')
  Future<HttpResponse<dynamic>> getBlockedUsers();

  @POST('/users/change_password')
  Future<HttpResponse<dynamic>> changePassword(@Body() Map<String, dynamic> body);

  @POST('/users/change_nickname')
  Future<HttpResponse<dynamic>> changeNickname(@Body() Map<String, dynamic> body);

  @GET('/users/notification_settings')
  Future<HttpResponse<dynamic>> getNotificationSettings();

  @PATCH('/users/notification_settings')
  Future<HttpResponse<dynamic>> updateNotificationSettings(@Body() Map<String, dynamic> body);

  @POST('/users/update_push_token')
  Future<HttpResponse<dynamic>> updatePushToken(@Body() Map<String, dynamic> body);

  @POST('/users/disable_push')
  Future<HttpResponse<dynamic>> disablePush();

  // ============ Broadcasts ============

  @GET('/broadcasts')
  Future<HttpResponse<dynamic>> getBroadcasts();

  @GET('/broadcasts/received')
  Future<HttpResponse<dynamic>> getReceivedBroadcasts();

  @GET('/broadcasts/{id}')
  Future<HttpResponse<dynamic>> getBroadcastById(@Path() int id);

  @PATCH('/broadcasts/{id}/mark_as_read')
  Future<HttpResponse<dynamic>> markBroadcastAsRead(@Path() int id);

  @POST('/broadcasts/{id}/toggle_favorite')
  Future<HttpResponse<dynamic>> toggleBroadcastFavorite(@Path() int id);

  @DELETE('/broadcasts/{id}')
  Future<HttpResponse<dynamic>> deleteBroadcast(@Path() int id);

  // ============ Conversations ============

  @GET('/conversations')
  Future<HttpResponse<dynamic>> getConversations();

  @GET('/conversations/{id}')
  Future<HttpResponse<dynamic>> getConversationById(@Path() int id);

  @GET('/conversations/{id}/messages')
  Future<HttpResponse<dynamic>> getConversationMessages(@Path() int id);

  @POST('/conversations/{id}/favorite')
  Future<HttpResponse<dynamic>> toggleConversationFavorite(@Path() int id);

  @POST('/conversations/{id}/mark_as_read')
  Future<HttpResponse<dynamic>> markConversationAsRead(@Path() int id);

  @POST('/conversations/{id}/close')
  Future<HttpResponse<dynamic>> closeConversation(@Path() int id);

  @DELETE('/conversations/{id}')
  Future<HttpResponse<dynamic>> deleteConversation(@Path() int id);

  // ============ Notifications ============

  @GET('/notifications')
  Future<HttpResponse<dynamic>> getNotifications();

  @PATCH('/notifications/{id}/mark_as_read')
  Future<HttpResponse<dynamic>> markNotificationAsRead(@Path() int id);

  @PATCH('/notifications/mark_all_as_read')
  Future<HttpResponse<dynamic>> markAllNotificationsAsRead();

  @GET('/notifications/unread_count')
  Future<HttpResponse<dynamic>> getUnreadNotificationCount();

  // ============ Wallets ============

  @GET('/wallet')
  Future<HttpResponse<dynamic>> getWallet();

  @GET('/wallets/my_wallet')
  Future<HttpResponse<dynamic>> getMyWallet();

  @GET('/wallets/transactions')
  Future<HttpResponse<dynamic>> getWalletTransactions();

  @POST('/wallets/deposit')
  Future<HttpResponse<dynamic>> depositToWallet(@Body() Map<String, dynamic> body);

  // ============ Reports ============

  @POST('/reports')
  Future<HttpResponse<dynamic>> createReport(@Body() Map<String, dynamic> body);

  // ============ Health Check ============

  @GET('/health')
  Future<HttpResponse<dynamic>> healthCheck();
}
