import 'package:wp_frontend/api/base_api_functions.dart';
import 'package:wp_frontend/api/route/auth.dart';
import 'package:wp_frontend/api/route/drives.dart';
import 'package:wp_frontend/api/route/stops.dart';
import 'package:wp_frontend/api/route/travels.dart';
import 'package:wp_frontend/api/route/users.dart';
import 'package:wp_frontend/api/route/wanderpi.dart';


class Api {
  late AuthApiEndpoint _authApiEndpoint;
  late DrivesApiEndpoint _drivesApiEndpoint;
  late StopApiEndpoint _stopApiEndpoint;
  late TravelApiEndpoint _travelApiEndpoint;
  late UserApiEndpoint _userApiEndpoint;
  late WanderpiApiEndpoint _wanderpiApiEndpoint;

  driveApiEndpoint() => _drivesApiEndpoint;
  stopApiEndpoint() => _stopApiEndpoint;
  travelApiEndpoint() => _travelApiEndpoint;
  userApiEndpoint() => _userApiEndpoint;
  wanderpiApiEndpoint() => _wanderpiApiEndpoint;
  authApiEndpoint() => _authApiEndpoint;

  String API_BASE_URL = '';

  static final Api _instance = Api._internal();

  Api._internal();

  static Api get instance => _instance;


  // init class with all api endpoints
  factory Api(String base_url) {

    _instance.API_BASE_URL = base_url;

    _instance._userApiEndpoint = UserApiEndpoint(
        API_ENDPOINT: "${base_url}users/", BASE_URL: base_url);

    // userApiEndpoint() => _userApiEndpoint;


    _instance._travelApiEndpoint = TravelApiEndpoint(
        API_ENDPOINT: "${base_url}travels/", BASE_URL: base_url);

    // travelApiEndpoint() => _travelApiEndpoint;

    _instance._stopApiEndpoint = StopApiEndpoint(
        API_ENDPOINT: "${base_url}stops/", BASE_URL: base_url);

    // stopApiEndpoint() => _stopApiEndpoint;

    _instance._authApiEndpoint = AuthApiEndpoint(
        API_ENDPOINT: "${base_url}token/", BASE_URL: base_url);

    // authApiEndpoint() => _authApiEndpoint;

    _instance._wanderpiApiEndpoint = WanderpiApiEndpoint(
        API_ENDPOINT: "${base_url}wanderpis/", BASE_URL: base_url);

    // wanderpiApiEndpoint() => _wanderpiApiEndpoint;

    _instance._drivesApiEndpoint = DrivesApiEndpoint(
        API_ENDPOINT: "${base_url}drives/", BASE_URL: base_url);

    return _instance;
  }
}