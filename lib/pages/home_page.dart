import 'package:expense_tracker/auth/auth_service.dart';
import 'package:expense_tracker/bar%20graph/bar_graph.dart';
import 'package:expense_tracker/components/my_list_tile.dart';
import 'package:expense_tracker/database/expense_database.dart';
import 'package:expense_tracker/helpers/helper_functions.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //text editors
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  int? selectedMonthIndex; // months since startMonth

  // future to load graph data
  Future<Map<String, double>>? _monthlyTotalsFuture;

  @override
  void initState() {
    //read db on initial startup
    Provider.of<ExpenseDatabase>(context, listen: false).readExpense();

    // load futures
    refreshData();

    super.initState();
  }

  // refresh graph data
  void refreshData() {
    _monthlyTotalsFuture =
        Provider.of<ExpenseDatabase>(
          context,
          listen: false,
        ).calculateMonthlyTotals();
  }

  // open new expense box
  void openNewExpenseBox() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("New Expense"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //user input -> expense name
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(hintText: "Name"),
                ),

                //user input user amount
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(hintText: "Amount"),
                ),
              ],
            ),
            actions: [
              // cancel button
              _cancelButton(),

              //save button
              _createNewExpenseButton(),
            ],
          ),
    );
  }

  // open edit box
  void openEditBox(Expense expense) {
    //pre filled existing values into textibles
    String existingName = expense.name;
    String existingAmount = expense.amount.toString();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Edit Expense"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //user input -> expense name
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(hintText: existingName),
                ),

                //user input user amount
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(hintText: existingAmount),
                ),
              ],
            ),
            actions: [
              // cancel button
              _cancelButton(),

              //save button
              _editExpenseButton(expense),
            ],
          ),
    );
  }

  // open delete box
  void openDeleteBox(Expense expense) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Delete Expense?"),
            actions: [
              // cancel button
              _cancelButton(),

              //delete button
              _deleteExpenseButton(expense.id),
            ],
          ),
    );
  }

  void _handleBarTapped(int index) {
    setState(() {
      selectedMonthIndex = index;
    });
  }

  void logout() {
    final authservice = AuthService();
    authservice.signout();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDatabase>(
      builder: (context, value, child) {
        //get dates
        int startMonth = value.getStartMonth();
        int startYear = value.getStartYear();
        int currentMonth = DateTime.now().month;
        int currentYear = DateTime.now().year;

        // calculate the number of months since the first month
        int monthCount = calculateMonthCount(
          startYear,
          startMonth,
          currentYear,
          currentMonth,
        );

        // only display the expense for the current month
        // determine which month to show
        int monthOffset = selectedMonthIndex ?? (currentMonth - startMonth);
        int displayMonth = (startMonth + monthOffset - 1) % 12 + 1;
        int displayYear = startYear + (startMonth + monthOffset - 1) ~/ 12;

        List<Expense> displayedExpenses =
            value.allExpense.where((expense) {
              return expense.date.year == displayYear &&
                  expense.date.month == displayMonth;
            }).toList();

        // calculate total for selected month
        double selectedMonthTotal = displayedExpenses.fold(
          0,
          (sum, expense) => sum + expense.amount,
        );

        // return UI
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('\$${selectedMonthTotal.toStringAsFixed(2)}'),
                Text('${getCurrentMonthName(displayMonth)} $displayYear'),
              ],
            ),
          ),
          drawer: Drawer(
            backgroundColor: Colors.white,
            child: Padding(
              padding: EdgeInsets.only(top: 160.0, left: 8),
              child: Column(
                children: [
                  //its common to place a drawer header here

                  // home page title
                  ListTile(
                    leading: Icon(Icons.home),
                    title: Text('Home'),
                    onTap: () {
                      //pop the drawer
                      Navigator.pop(context);
                      //go to home page
                      Navigator.pushNamed(context, '/homepage');
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.contact_phone_rounded),
                    title: Text('About Us'),
                    onTap: () {
                      //pop the drawer
                      Navigator.pop(context);
                      //go to home page
                      Navigator.pushNamed(context, '/aboutus');
                    },
                  ),
                  const Spacer(),
                  ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Logout'),
                    onTap: () {
                      logout();
                      //pop the drawer
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),

          backgroundColor: Colors.white,
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color.fromARGB(255, 40, 40, 220),
            onPressed: openNewExpenseBox,
            child: const Icon(Icons.add, color: Colors.white),
          ),
          body: SafeArea(
            child: Column(
              children: [
                //gRAPH UI
                SizedBox(
                  height: 250,
                  child: FutureBuilder(
                    future: _monthlyTotalsFuture,
                    builder: (context, snapshot) {
                      //data is loaded
                      if (snapshot.connectionState == ConnectionState.done) {
                        Map<String, double> monthlyTotals = snapshot.data ?? {};

                        //create the list of monthly summary
                        List<double>
                        monthlySummary = List.generate(monthCount, (index) {
                          // callculate tht year and the month
                          int year = startYear + (startMonth + index - 1) ~/ 12;
                          int month = (startMonth + index - 1) % 12 + 1;

                          // create the key in the format 'year month'
                          String yearMonthKey = '$year-$month';

                          //return the total for year-month or 0.0 if non-existent
                          return monthlyTotals[yearMonthKey] ?? 0.0;
                        });
                        return MyBarGraph(
                          monthlySummary: monthlySummary,
                          startMonth: startMonth,
                          onBarTapped: _handleBarTapped,
                        );
                      }
                      //loading
                      else {
                        return const Center(child: Text('Loading..'));
                      }
                    },
                  ),
                ),

                const SizedBox(height: 25),

                // expense list UI
                Expanded(
                  child: ListView.builder(
                    itemCount: displayedExpenses.length,
                    itemBuilder: (context, index) {
                      // reverse the index to show the latest item first
                      int reversedIndex = displayedExpenses.length - 1 - index;

                      //get individual expense
                      Expense individualExpense =
                          displayedExpenses[reversedIndex];

                      //return list title UI
                      return MyListTile(
                        tittle: individualExpense.name,
                        trailing: formatAmount(individualExpense.amount),
                        onEditPressed:
                            (context) => openEditBox(individualExpense),
                        onDeletePressed:
                            (context) => openDeleteBox(individualExpense),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // cancel button
  Widget _cancelButton() {
    return MaterialButton(
      onPressed: () {
        //pop box
        Navigator.pop(context);

        //clear controller
        nameController.clear();
        amountController.clear();
      },
      child: const Text('Cancel'),
    );
  }

  // save button => create new expense
  Widget _createNewExpenseButton() {
    return MaterialButton(
      onPressed: () async {
        // only save if there is something in the textfield to save
        if (nameController.text.isNotEmpty &&
            amountController.text.isNotEmpty) {
          //pop box
          Navigator.pop(context);

          //create an expense
          Expense newExpense = Expense(
            name: nameController.text,
            amount: convertStringToDouble(amountController.text),
            date: DateTime.now(),
          );

          //save to db
          await context.read<ExpenseDatabase>().createNewExpense(newExpense);

          //refresh the graph
          refreshData();

          //clear controllers
          nameController.clear();
          amountController.clear();
        }
      },
      child: const Text("Save"),
    );
  }

  // save button -> Edit existing expense
  Widget _editExpenseButton(Expense expense) {
    return MaterialButton(
      onPressed: () async {
        //save as long as at least one textfield has been changed
        if (nameController.text.isNotEmpty ||
            amountController.text.isNotEmpty) {
          //pop box
          Navigator.pop(context);

          //create a new updated expense
          Expense updatedExpense = Expense(
            name:
                nameController.text.isNotEmpty
                    ? nameController.text
                    : expense.name,
            amount:
                amountController.text.isNotEmpty
                    ? convertStringToDouble(amountController.text)
                    : expense.amount,
            date: DateTime.now(),
          );
          // old expense id
          int existingId = expense.id;

          //save to db
          await context.read<ExpenseDatabase>().updateExxpense(
            existingId,
            updatedExpense,
          );

          //refresh the graph
          refreshData();
        }
      },
      child: const Text("Save"),
    );
  }

  //delete button
  Widget _deleteExpenseButton(int id) {
    return MaterialButton(
      onPressed: () async {
        //pop box
        Navigator.pop(context);

        //delete expense from db
        await context.read<ExpenseDatabase>().deleteExpense(id);

        //refresh the graph
        refreshData();
      },
      child: const Text("Delete"),
    );
  }
}
