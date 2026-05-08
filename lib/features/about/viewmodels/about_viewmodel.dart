import 'package:package_info_plus/package_info_plus.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutViewModel {
  final BehaviorSubject<String> version$ = BehaviorSubject.seeded('');
  final BehaviorSubject<bool> urlLaunchFailed$ = BehaviorSubject.seeded(false);

  AboutViewModel() {
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!version$.isClosed) version$.add(info.version);
    } catch (_) {
      if (!version$.isClosed) version$.add('');
    }
  }

  Future<void> launchExternalUrl(String url) async {
    try {
      final ok = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (!ok && !urlLaunchFailed$.isClosed) {
        urlLaunchFailed$.add(true);
        urlLaunchFailed$.add(false);
      }
    } catch (_) {
      if (!urlLaunchFailed$.isClosed) {
        urlLaunchFailed$.add(true);
        urlLaunchFailed$.add(false);
      }
    }
  }

  void dispose() {
    version$.close();
    urlLaunchFailed$.close();
  }
}
