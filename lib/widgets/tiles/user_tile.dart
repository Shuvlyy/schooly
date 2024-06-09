import 'package:flutter/material.dart';
import 'package:schooly/common/scolors.dart';
import 'package:schooly/models/user/suser.dart';

class UserTile extends StatelessWidget {
  final SUser user;

  const UserTile({
    super.key,

    required this.user
  });

  static Widget shimmerLoading(BuildContext context) {
    final Color loadingColor = SColors.getGreyscaleColor(context).withOpacity(0.1);

    return Material(
      color: SColors.getBackgroundColor(context),
      child: InkWell(
        // onTap: () {

        // },
        borderRadius: BorderRadius.circular(15.0),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Flex(
            direction: Axis.horizontal,
            children: <Widget>[
              Container(
                height: 42.0,
                width: 42.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: loadingColor
                ),
              ),
              const SizedBox(width: 10.0),
              Container(
                height: 20.0,
                width: 80.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: loadingColor
                ),
              ),
              const SizedBox(width: 10.0),
              Container(
                height: 12.0,
                width: 70.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: loadingColor
                ),
              )
            ],
          )
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SColors.getBackgroundColor(context),
      child: InkWell(
        onTap: () {

        },
        borderRadius: BorderRadius.circular(15.0),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Flex(
            direction: Axis.horizontal,
            children: <Widget>[
              Container(
                height: 42.0,
                width: 42.0,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('assets/images/default-pfp.png')
                  )
                ),
              ),

              const SizedBox(width: 15.0),
              Expanded(
                child: Wrap(
                  direction: Axis.horizontal,
                  spacing: 10.0,
                  children: <Text>[
                    Text(
                      user.userData.profile.displayName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 20.0
                      ),
                    ),

                    Text(
                      "@${user.userData.profile.username}",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: SColors.getGreyscaleColor(context)
                      ),
                    )
                  ],
                )
              ),

              // Expanded(child: Container()),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 20.0,
              )
            ],
          )
        )
      )
    );
  }
}