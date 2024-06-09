import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:schooly/common/scolors.dart';
import 'package:schooly/layouts/default_page_layout.dart';
import 'package:schooly/models/user/suser.dart';
import 'package:schooly/widgets/gradient_scaffold.dart';
import 'package:schooly/widgets/slogo.dart';
import 'package:schooly/widgets/sappbar.dart';

class ClassPage extends StatefulWidget {
  const ClassPage({super.key});

  @override
  State<ClassPage> createState() => _ClassPageState();
}

class _ClassPageState extends State<ClassPage> {
  @override
  Widget build(BuildContext context) {
    final Stream<SUser> userStream = GetIt.I<Stream<SUser>>();

    return StreamBuilder(
      stream: userStream,
      builder: (
        BuildContext context,
        AsyncSnapshot<SUser> snapshot
      ) {
        // SUser user = GetIt.I<SUser>();

        if (snapshot.hasData) {
          GetIt.I.registerSingleton<SUser>(snapshot.data!);
        }

        return GradientScaffold(
          gradient: SColors.getScaffoldGradient(context),
          appBar: const SAppBar(
            title: SLogo(),
          ),
          body: DefaultPageLayout(
            body: <Widget>[
              Center(
                child: Text(
                  'Soon...',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              )
            ],
          ),
        );
      }
    );
  }
}