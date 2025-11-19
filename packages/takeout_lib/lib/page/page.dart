// Copyright 2023 defsub
//
// This file is part of TakeoutFM.
//
// TakeoutFM is free software: you can redistribute it and/or modify it under the
// terms of the GNU Affero General Public License as published by the Free
// Software Foundation, either version 3 of the License, or (at your option)
// any later version.
//
// TakeoutFM is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for
// more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with TakeoutFM.  If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/client/client.dart';
import 'package:takeout_lib/context/context.dart';
import 'package:takeout_lib/empty.dart';

abstract mixin class ClientPageBuilder<T> {
  WidgetBuilder builder(BuildContext context, {T? value}) {
    final builder = (context) => BlocProvider(
      create: (context) => ClientCubit(context.clientRepository),
      child: BlocBuilder<ClientCubit, ClientState>(
        builder: (context, state) {
          if (state is ClientReady) {
            if (value != null) {
              return page(context, value);
            } else {
              load(context);
              // TODO upon first load ClientLoading is delayed so show some
              //  progress now
              return const Center(child: CircularProgressIndicator());
            }
          } else if (state is ClientLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ClientResult<T>) {
            return page(context, state.result);
          } else if (state is ClientError) {
            return errorPage(context, state);
          }
          return const EmptyWidget();
        },
      ),
    );
    return builder;
  }

  Widget page(BuildContext context, T state);

  Widget errorPage(BuildContext context, ClientError error) {
    return Center(
      child: TextButton(
        child: Text('Try Again (${error.error})'),
        onPressed: () => reloadPage(context),
      ),
    );
  }

  Future<void> reloadPage(BuildContext context) {
    return reload(context);
  }

  Future<void> load(BuildContext context, {Duration? ttl});

  Future<void> reload(BuildContext context) {
    return load(context, ttl: Duration.zero);
  }
}

abstract class ClientPage<T> extends StatelessWidget with ClientPageBuilder<T> {
  final T? value;

  ClientPage({super.key, this.value});

  @override
  Widget build(BuildContext context) {
    return builder(context, value: value)(context);
  }
}
