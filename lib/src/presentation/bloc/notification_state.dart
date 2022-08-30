part of 'notification_cubit.dart';

abstract class NotificationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationDataState<T> extends NotificationState {
  final FcmDataModel data;
  final T? pushData;

  NotificationDataState(this.data, {this.pushData});

  @override
  List<Object?> get props => [data, pushData];
}
