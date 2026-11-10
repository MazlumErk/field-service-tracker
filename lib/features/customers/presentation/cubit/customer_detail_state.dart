import 'package:equatable/equatable.dart';
import 'package:field_service_tracker/core/errors/app_exception.dart';
import 'package:field_service_tracker/core/utils/calendar_date.dart';
import 'package:field_service_tracker/features/customers/domain/customer.dart';
import 'package:field_service_tracker/features/maintenance/domain/device_maintenance_overview.dart';

enum CustomerDetailStatus { loading, success, notFound, failure }

/// Steps of the delete flow. The UI reacts to [confirming] by showing the
/// confirmation dialog and to [deleted] by leaving the page.
enum CustomerDeletionStep { idle, loadingImpact, confirming, deleting, deleted }

final class CustomerDetailState extends Equatable {
  const CustomerDetailState({
    required this.today,
    this.status = CustomerDetailStatus.loading,
    this.customer,
    this.devices = const [],
    this.failure,
    this.deletionStep = CustomerDeletionStep.idle,
    this.deletionImpact,
    this.deletionFailure,
  });

  /// Reference day for maintenance statuses (from `AppClock`).
  final CalendarDate today;
  final CustomerDetailStatus status;
  final Customer? customer;
  final List<DeviceMaintenanceOverview> devices;
  final AppException? failure;

  final CustomerDeletionStep deletionStep;

  /// Set while [deletionStep] is [CustomerDeletionStep.confirming].
  final CustomerDeletionImpact? deletionImpact;

  /// Last delete error, shown once as a snackbar.
  final AppException? deletionFailure;

  bool get isBusy =>
      deletionStep == CustomerDeletionStep.loadingImpact ||
      deletionStep == CustomerDeletionStep.deleting;

  CustomerDetailState copyWith({
    CustomerDetailStatus? status,
    Customer? customer,
    List<DeviceMaintenanceOverview>? devices,
    AppException? failure,
    CustomerDeletionStep? deletionStep,
    CustomerDeletionImpact? deletionImpact,
    AppException? deletionFailure,
  }) {
    final nextStep = deletionStep ?? this.deletionStep;
    return CustomerDetailState(
      today: today,
      status: status ?? this.status,
      customer: customer ?? this.customer,
      devices: devices ?? this.devices,
      // Errors are one-shot: they are cleared by any following emit.
      failure: failure,
      deletionStep: nextStep,
      // The impact survives stream updates while the dialog is open and is
      // dropped once the flow leaves the confirming step.
      deletionImpact: nextStep == CustomerDeletionStep.confirming
          ? deletionImpact ?? this.deletionImpact
          : null,
      deletionFailure: deletionFailure,
    );
  }

  @override
  List<Object?> get props => [
    today,
    status,
    customer,
    devices,
    failure,
    deletionStep,
    deletionImpact,
    deletionFailure,
  ];
}
