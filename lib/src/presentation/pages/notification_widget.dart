import 'package:app_firebase_messagging/src/presentation/bloc/notification_cubit.dart';
import 'package:bloc_base_core/bloc_base_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class NotificationWidget extends StatefulWidget {
  final Widget child;

  const NotificationWidget({Key? key, required this.child}) : super(key: key);

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {
  final bloc = GetIt.I<NotificationCubit>();

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: bloc,
      listener: (_, state) {
        if (state is NotificationDataState) {
          Log.i(
              'NotificationDataState\n${state.data.toJson()}\n${state.pushData.toJson()}');
        }
      },
      child: widget.child,
    );
  }
}
