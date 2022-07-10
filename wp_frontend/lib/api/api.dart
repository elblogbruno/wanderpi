import 'package:wp_frontend/api/base_api_functions.dart';
import 'package:wp_frontend/api/route/auth.dart';
import 'package:wp_frontend/api/route/stops.dart';
import 'package:wp_frontend/api/route/travels.dart';
import 'package:wp_frontend/api/route/users.dart';
import 'package:wp_frontend/api/route/wanderpi.dart';


class Api {

  final UserApiEndpoint _userApiEndpoint = UserApiEndpoint(API_ENDPOINT: "${BaseApi().API_BASE_URL}users/", BASE_URL: BaseApi().API_BASE_URL);

  userApiEndpoint() => _userApiEndpoint;

  final TravelApiEndpoint _travelApiEndpoint = TravelApiEndpoint(API_ENDPOINT: "${BaseApi().API_BASE_URL}travels/", BASE_URL: BaseApi().API_BASE_URL);

  travelApiEndpoint() => _travelApiEndpoint;

  final StopApiEndpoint _stopApiEndpoint = StopApiEndpoint(API_ENDPOINT: "${BaseApi().API_BASE_URL}stops/", BASE_URL: BaseApi().API_BASE_URL);

  stopApiEndpoint() => _stopApiEndpoint;

  final AuthApiEndpoint _authApiEndpoint = AuthApiEndpoint(API_ENDPOINT: "${BaseApi().API_BASE_URL}token/", BASE_URL: BaseApi().API_BASE_URL);

  authApiEndpoint() => _authApiEndpoint;

  final WanderpiApiEndpoint _wanderpiApiEndpoint = WanderpiApiEndpoint(API_ENDPOINT: "${BaseApi().API_BASE_URL}Wanderpis/", BASE_URL: BaseApi().API_BASE_URL);

  wanderpiApiEndpoint() => _wanderpiApiEndpoint;
}