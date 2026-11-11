import 'package:equatable/equatable.dart';
import 'package:field_service_tracker/core/errors/app_exception.dart';
import 'package:field_service_tracker/features/settings/domain/demo_data_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum DemoResetStatus { idle, resetting, success, failure }

final class SettingsState extends Equatable {
  const SettingsState({this.resetStatus = DemoResetStatus.idle, this.failure});

  final DemoResetStatus resetStatus;

  /// Set when [resetStatus] is [DemoResetStatus.failure].
  final AppException? failure;

  bool get isResetting => resetStatus == DemoResetStatus.resetting;

  @override
  List<Object?> get props => [resetStatus, failure];
}

/// Settings logic: resetting the demo data.
///
/// The confirmation dialog is shown by the page; this Cubit only runs the
/// transactional reset (`DemoDataRepository.resetDemoData`) and reports the
/// outcome. Other screens update through their own repository streams.
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._demoData) : super(const SettingsState());

  final DemoDataRepository _demoData;

  /// Runs the reset once; calls while a reset is running are ignored.
  Future<void> resetDemoData() async {
    if (state.isResetting) return;
    emit(const SettingsState(resetStatus: DemoResetStatus.resetting));
    try {
      await _demoData.resetDemoData();
      emit(const SettingsState(resetStatus: DemoResetStatus.success));
    } catch (error, stackTrace) {
      // The repository rolled the transaction back: data is unchanged.
      emit(
        SettingsState(
          resetStatus: DemoResetStatus.failure,
          failure: toAppException(error, stackTrace),
        ),
      );
    }
  }
}
