import 'package:equatable/equatable.dart';

/// Build metadata shown in Settings. Loaded once at startup and provided via
/// `RepositoryProvider`, so widgets stay free of platform-channel calls.
final class AppInfo extends Equatable {
  const AppInfo({required this.version, required this.buildNumber});

  final String version;
  final String buildNumber;

  @override
  List<Object?> get props => [version, buildNumber];
}
