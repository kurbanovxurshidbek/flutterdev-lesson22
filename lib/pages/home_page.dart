import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:randomuser_cubit/bloc/home_cubit.dart';
import 'package:randomuser_cubit/bloc/home_state.dart';

import '../models/random_user_list_res.dart';
import '../services/log_service.dart';
import '../views/item_random_user.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeCubit homeCubit;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    homeCubit = BlocProvider.of<HomeCubit>(context);
    homeCubit.onLoadRandomUserList();

    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent <= scrollController.offset) {
        LogService.i(homeCubit.currentPage.toString());
        homeCubit.onLoadRandomUserList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("BloC - Cubit"),
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        buildWhen: (previous, current){
          //https://stackoverflow.com/questions/72105781/listview-update-via-bloc-pattern-issue
          return current is HomeRandomUserListState;
        },
        builder: (BuildContext context, HomeState state) {
          if (state is HomeErrorState) {
            return viewOfError(state.errorMessage);
          }

          if (state is HomeRandomUserListState) {
            var userList = state.userList;
            return viewOfRandomUserList(userList);
          }

          return viewOfLoading();
        },
      ),
    );
  }

  Widget viewOfError(String err) {
    return Center(
      child: Text("Error occurred $err"),
    );
  }

  Widget viewOfLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget viewOfRandomUserList(List<RandomUser> userList) {
    return ListView.builder(
      controller: scrollController,
      itemCount: userList.length,
      itemBuilder: (ctx, index) {
        return itemOfRandomUser(userList[index], index);
      },
    );
  }
}
