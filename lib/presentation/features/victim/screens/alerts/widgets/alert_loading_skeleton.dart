import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/core/widgets/shimmers/MinhShimmerEffect.dart';
import 'package:flutter/material.dart';

/// Loading skeleton for alert cards
class AlertLoadingSkeleton extends StatelessWidget {
  const AlertLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: MinhSizes.defaultSpace),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.only(bottom: MinhSizes.spaceBtwItems),
          child: Padding(
            padding: EdgeInsets.all(MinhSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header skeleton
                Row(
                  children: [
                    MinhShimmerEffect(
                      width: 40,
                      height: 40,
                      radius: MinhSizes.borderRadiusSm,
                    ),
                    SizedBox(width: MinhSizes.spaceBtwItems),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MinhShimmerEffect(
                            width: double.infinity,
                            height: 20,
                            radius: 4,
                          ),
                          SizedBox(height: MinhSizes.xs),
                          Row(
                            children: [
                              MinhShimmerEffect(
                                width: 80,
                                height: 16,
                                radius: 4,
                              ),
                              SizedBox(width: 6),
                              MinhShimmerEffect(
                                width: 100,
                                height: 16,
                                radius: 4,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MinhSizes.spaceBtwItems),
                // Content skeleton
                MinhShimmerEffect(
                  width: double.infinity,
                  height: 16,
                  radius: 4,
                ),
                SizedBox(height: 8),
                MinhShimmerEffect(
                  width: double.infinity * 0.8,
                  height: 16,
                  radius: 4,
                ),
                SizedBox(height: MinhSizes.spaceBtwItems),
                // Meta info skeleton
                Row(
                  children: [
                    MinhShimmerEffect(
                      width: 100,
                      height: 14,
                      radius: 4,
                    ),
                    SizedBox(width: 16),
                    MinhShimmerEffect(
                      width: 120,
                      height: 14,
                      radius: 4,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}





















