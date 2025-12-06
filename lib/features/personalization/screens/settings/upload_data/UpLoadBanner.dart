import 'package:cuutrobaolu/common/widgets/appbar/MinhAppbar.dart';
import 'package:cuutrobaolu/common/widgets/list_titles/MinhSettingsMenuTitle.dart';
import 'package:cuutrobaolu/util/constants/sizes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class UploadBanner extends StatelessWidget {
  const UploadBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MinhAppbar(
        title: Text("UpLoad Banner"),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(MinhSizes.defaultSpace),
        child: Form(
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Target Screen",
                ),
              ),
              MinhSettingsMenuTitle(
                icon: Iconsax.activity,
                title: "Geolocation",
                subtitle: "Set Shopping delivery address",
                trailing: Switch(
                  value: true,
                  onChanged: (value) {

                  },
                ),
                onTap: (){},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
