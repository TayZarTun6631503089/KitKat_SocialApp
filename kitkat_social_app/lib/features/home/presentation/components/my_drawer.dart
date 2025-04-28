import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kitkat_social_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:kitkat_social_app/features/home/presentation/components/my_drawer_tile.dart';
import 'package:kitkat_social_app/features/profile/presentation/pages/profile_page.dart';
import 'package:kitkat_social_app/features/search/presentation/pages/search_page.dart';
import 'package:kitkat_social_app/features/settings/pages/settings_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              SizedBox(height: 50),

              // Logo
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50.0),
                child: Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(shape: BoxShape.circle),
                  child: Image.asset("assets/logo/KitKatLogo.png"),
                ),

                // Icon(
                //   Icons.person,
                //   size: 80,
                //   color: Theme.of(context).colorScheme.primary,
                // ),
              ),

              Divider(color: Theme.of(context).colorScheme.secondary),
              // home tile
              MyDrawerTile(
                title: "H O M E",
                icon: Icons.home,
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              // profile tile
              MyDrawerTile(
                title: "P R O F I L E",
                icon: Icons.person,
                onTap: () {
                  //Poping menu
                  Navigator.pop(context);
                  //get current user id
                  final user = context.read<AuthCubit>().currentUser;
                  String? uid = user!.uid;

                  // nevigate
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(uid: uid),
                    ),
                  );
                },
              ),

              // search tile
              MyDrawerTile(
                title: "S E A R C H",
                icon: Icons.search,
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SearchPage()),
                    ),
              ),

              // settings tile
              MyDrawerTile(
                title: "S E T T I N G S",
                icon: Icons.settings,
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsPage()),
                    ),
              ),

              Spacer(),
              // logout tile
              MyDrawerTile(
                title: "L O G O U T",
                icon: Icons.logout,
                onTap: () {
                  context.read<AuthCubit>().logout();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
