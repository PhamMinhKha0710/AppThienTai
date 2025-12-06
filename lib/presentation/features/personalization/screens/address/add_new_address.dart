import 'package:cuutrobaolu/core/widgets/appbar/MinhAppbar.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class AddNewAddressScreen extends StatelessWidget {
  const AddNewAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MinhAppbar(
        title: Text("Add Address"),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(MinhSizes.defaultSpace),
          child: Form(
              child: Column(
                children: [
                  TextFormField(
                    expands: false,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Iconsax.user),
                      labelText: "User",
                    ),
                  ),
                  SizedBox(height: MinhSizes.spaceBtwItems,),
                  TextFormField(
                    expands: false,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Iconsax.mobile),
                      labelText: "Phone Number",
                    ),
                  ),
                  SizedBox(height: MinhSizes.spaceBtwItems,),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          expands: false,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Iconsax.building_31),
                            labelText: "Street",
                          ),
                        ),
                      ),
                      SizedBox(width: MinhSizes.spaceBtwInputFields,),
                      Expanded(
                        child: TextFormField(
                          expands: false,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Iconsax.code),
                            labelText: "Postal Code",
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MinhSizes.spaceBtwItems,),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          expands: false,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Iconsax.building),
                            labelText: "City",
                          ),
                        ),
                      ),
                      SizedBox(width: MinhSizes.spaceBtwInputFields,),
                      Expanded(
                        child: TextFormField(
                          expands: false,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Iconsax.activity),
                            labelText: "State",
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MinhSizes.spaceBtwItems,),
                  TextFormField(
                    expands: false,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Iconsax.global),
                      labelText: "Country",
                    ),
                  ),
                  SizedBox(height: MinhSizes.spaceBtwSections,),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: (){},
                        child: Text("Save"),
                    ),
                  ),
                ],
              )
          ),
        ),
      ),
    );
  }
}

