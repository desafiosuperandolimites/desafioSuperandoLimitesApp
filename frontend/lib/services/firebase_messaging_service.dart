// services/firebase_messaging_service.dart

part of 'env_services.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final String? baseUrl = dotenv.env['BASE_URL'];

  Future<void> initialize() async {
    // Request permissions if needed
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('User granted permission');
      }

      // Get the token
      String? token = await _messaging.getToken();
      if (kDebugMode) {
        print('FCM Token: $token');
      }

      // Store the token locally
      await storeTokenLocally(token);

      // Handle token refresh
      _messaging.onTokenRefresh.listen((newToken) async {
        if (kDebugMode) {
          print('New FCM Token: $newToken');
        }

        // Store the new token locally
        await storeTokenLocally(newToken);

        // If the user is logged in, send the new token to the backend
        final UserController userController = UserController();
        await userController.fetchCurrentUser();
        final user = userController.user;
        final userId = user?.id;
        if (userId != null) {
          final response = await http.put(
            Uri.parse('$baseUrl/auth/update-fcm-token'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: {'userId': userId, 'fcmToken': token},
          );

          if (response.statusCode != 200) {
            final Map<String, dynamic> responseBody = jsonDecode(response.body);
            String errorMessage =
                responseBody['error'] ?? 'Ocorreu um erro inesperado';
            throw errorMessage;
          }
        }
      });
    } else {
      if (kDebugMode) {
        print('User declined or has not accepted permission');
      }
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print(
          'Received a message in the foreground: ${message.notification?.title}');
      }

      if (message.notification != null) {
        NotificationController.showNotification(
          title: message.notification!.title ?? '',
          body: message.notification!.body ?? '',
        );
      }
    });

    // Handle background messages (optional)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle the message when the app is opened from a notification
      if (kDebugMode) {
        print('Message clicked!');
      }
    });
  }

  Future<void> storeTokenLocally(String? token) async {
    if (token != null) {
      await _storage.write(key: 'fcm_token', value: token);
    }
  }
}
