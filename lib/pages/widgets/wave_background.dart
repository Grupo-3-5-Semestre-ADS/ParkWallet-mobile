import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:park_wallet/constants/app_colors.dart';

class WaveBackground extends StatelessWidget {
  final bool opaque;

  const WaveBackground({super.key, this.opaque = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: AppColors.white),

        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            height: 150,
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.fill,
              alignment: Alignment.bottomCenter,
              child: SvgPicture.asset(
                'assets/images/bottom_waves.svg',
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),
        ),

        if (true) Container(
          color: opaque ? AppColors.very_light_grey.withAlpha(220) : Colors.transparent,
        ),
      ],
    );
  }
}
