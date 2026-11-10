import 'dart:async';

import 'package:field_service_tracker/core/clock/app_clock.dart';
import 'package:field_service_tracker/core/errors/app_exception.dart';
import 'package:field_service_tracker/core/utils/calendar_date.dart';
import 'package:field_service_tracker/features/customers/domain/customer.dart';
import 'package:field_service_tracker/features/customers/domain/customer_repository.dart';
import 'package:field_service_tracker/features/customers/presentation/cubit/customer_detail_state.dart';
import 'package:field_service_tracker/features/maintenance/domain/device_maintenance_overview.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Customer detail: the customer, its devices with maintenance state, and
/// the confirmed delete flow.
///
/// Combines two repository streams; both subscriptions are cancelled in
/// [close].
class CustomerDetailCubit extends Cubit<CustomerDetailState> {
  CustomerDetailCubit({
    required this.customerId,
    required CustomerRepository customerRepository,
    required MaintenanceRepository maintenanceRepository,
    required AppClock clock,
  }) : _customers = customerRepository,
       _maintenance = maintenanceRepository,
       super(CustomerDetailState(today: CalendarDate.today(clock)));

  final int customerId;
  final CustomerRepository _customers;
  final MaintenanceRepository _maintenance;

  StreamSubscription<Customer?>? _customerSubscription;
  StreamSubscription<List<DeviceMaintenanceOverview>>? _devicesSubscription;

  Customer? _latestCustomer;
  List<DeviceMaintenanceOverview>? _latestDevices;
  bool _customerReceived = false;

  void load() {
    unawaited(_customerSubscription?.cancel());
    unawaited(_devicesSubscription?.cancel());
    _customerReceived = false;
    _latestDevices = null;

    _customerSubscription = _customers.watchCustomer(customerId).listen((
      customer,
    ) {
      _customerReceived = true;
      _latestCustomer = customer;
      _emitCombined();
    }, onError: _onStreamError);
    _devicesSubscription = _maintenance
        .watchCustomerOverview(customerId)
        .listen((devices) {
          _latestDevices = devices;
          _emitCombined();
        }, onError: _onStreamError);
  }

  void retry() {
    emit(state.copyWith(status: CustomerDetailStatus.loading));
    load();
  }

  void _emitCombined() {
    // After a successful delete the customer stream emits `null`; keep the
    // last content on screen while the page navigates away.
    if (state.deletionStep == CustomerDeletionStep.deleted) return;
    if (!_customerReceived) return;

    final customer = _latestCustomer;
    if (customer == null) {
      emit(state.copyWith(status: CustomerDetailStatus.notFound));
      return;
    }
    final devices = _latestDevices;
    if (devices == null) return;
    emit(
      state.copyWith(
        status: CustomerDetailStatus.success,
        customer: customer,
        devices: devices,
      ),
    );
  }

  void _onStreamError(Object error, StackTrace stackTrace) {
    emit(
      state.copyWith(
        status: CustomerDetailStatus.failure,
        failure: toAppException(error, stackTrace),
      ),
    );
  }

  /// Step 1: load what would be deleted and ask the UI for confirmation.
  Future<void> requestDeletion() async {
    if (state.deletionStep != CustomerDeletionStep.idle) return;
    emit(state.copyWith(deletionStep: CustomerDeletionStep.loadingImpact));
    try {
      final impact = await _customers.getDeletionImpact(customerId);
      emit(
        state.copyWith(
          deletionStep: CustomerDeletionStep.confirming,
          deletionImpact: impact,
        ),
      );
    } catch (error, stackTrace) {
      emit(
        state.copyWith(
          deletionStep: CustomerDeletionStep.idle,
          deletionFailure: toAppException(error, stackTrace),
        ),
      );
    }
  }

  /// The user dismissed the dialog: nothing is deleted.
  void cancelDeletion() {
    if (state.deletionStep != CustomerDeletionStep.confirming) return;
    emit(state.copyWith(deletionStep: CustomerDeletionStep.idle));
  }

  /// Step 2: the user confirmed; runs the transactional cascade delete.
  Future<void> confirmDeletion() async {
    if (state.deletionStep != CustomerDeletionStep.confirming) return;
    emit(state.copyWith(deletionStep: CustomerDeletionStep.deleting));
    try {
      await _customers.deleteCustomer(customerId);
      emit(state.copyWith(deletionStep: CustomerDeletionStep.deleted));
    } catch (error, stackTrace) {
      emit(
        state.copyWith(
          deletionStep: CustomerDeletionStep.idle,
          deletionFailure: toAppException(error, stackTrace),
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _customerSubscription?.cancel();
    await _devicesSubscription?.cancel();
    return super.close();
  }
}
