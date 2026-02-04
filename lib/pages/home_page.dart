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

  @override
  void dispose() {
    nameController.dispose();
    amountController.dispose();
    super.dispose();
  }

  // refresh graph data
  void refreshData() {
    _monthlyTotalsFuture = Provider.of<ExpenseDatabase>(
      context,
      listen: false,
    ).calculateMonthlyTotals();
  }

  // open new expense box
  void openNewExpenseBox() {
    nameController.clear();
    amountController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Expense"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //user input -> expense name
            TextField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: "Name",
                hintText: "Groceries, Uber, Rent",
              ),
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: 14),

            //user input user amount
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: "Amount",
                hintText: "0.00",
              ),
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
    nameController.text = existingName;
    amountController.text = existingAmount;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Expense"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //user input -> expense name
            TextField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: "Name"),
              textInputAction: TextInputAction.next,
            ),

            //user input user amount
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: "Amount"),
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
      builder: (context) => AlertDialog(
        title: const Text("Delete Expense?"),
        content: Text(
          'Delete "${expense.name}" from your expenses?',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

        List<Expense> displayedExpenses = value.allExpense.where((expense) {
          return expense.date.year == displayYear &&
              expense.date.month == displayMonth;
        }).toList();

        // calculate total for selected month
        double selectedMonthTotal = displayedExpenses.fold(
          0,
          (sum, expense) => sum + expense.amount,
        );

        final monthLabel = '${getCurrentMonthName(displayMonth)} $displayYear';

        // return UI
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            title: const Text(
              "Overview",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          drawer: Drawer(
            backgroundColor: Colors.white,
            child: SafeArea(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: const BoxDecoration(color: Color(0xFFF2F5F9)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Color(0xFF1B3A57),
                          child: Icon(Icons.wallet, color: Colors.white),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "Expense Tracker",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Track spending with clarity",
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: const CircleAvatar(
                      radius: 16,
                      backgroundColor: Color(0xFF1B3A57),
                      child: Icon(
                        Icons.home_max_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    title: const Text(
                      'Home',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/homepage');
                    },
                  ),
                  ListTile(
                    leading: const CircleAvatar(
                      radius: 16,
                      backgroundColor: Color(0xFFE38B37),
                      child: Icon(
                        Icons.contact_phone_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    title: const Text(
                      'About Us',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/aboutus');
                    },
                  ),
                  const Divider(height: 32),
                  ListTile(
                    leading: const CircleAvatar(
                      radius: 16,
                      backgroundColor: Color(0xFFD95555),
                      child: Icon(Icons.logout, color: Colors.white, size: 18),
                    ),
                    title: const Text(
                      'Logout',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onTap: () {
                      logout();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),

          backgroundColor: Colors.white,
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: const Color(0xFF1B3A57),
            onPressed: openNewExpenseBox,
            label: const Text(
              "Add Expense",
              style: TextStyle(color: Colors.white),
            ),
            icon: const Icon(Icons.add, color: Colors.white),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F5F9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  monthLabel,
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  formatAmount(selectedMonthTotal),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Transactions",
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "${displayedExpenses.length}",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Spending Trend",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 240,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.black.withValues(alpha: 0.06),
                          ),
                        ),
                        child: Center(
                          child: FutureBuilder(
                            future: _monthlyTotalsFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                Map<String, double> monthlyTotals =
                                    snapshot.data ?? {};

                                List<double> monthlySummary = List.generate(
                                  monthCount,
                                  (index) {
                                    int year =
                                        startYear +
                                        (startMonth + index - 1) ~/ 12;
                                    int month =
                                        (startMonth + index - 1) % 12 + 1;
                                    String yearMonthKey = '$year-$month';
                                    return monthlyTotals[yearMonthKey] ?? 0.0;
                                  },
                                );
                                return MyBarGraph(
                                  monthlySummary: monthlySummary,
                                  startMonth: startMonth,
                                  onBarTapped: _handleBarTapped,
                                );
                              } else {
                                return const Center(child: Text('Loading..'));
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        "Transactions",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),

                // expense list UI
                Expanded(
                  child: displayedExpenses.isEmpty
                      ? Center(
                          child: Text(
                            "No expenses yet for $monthLabel.",
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        )
                      : ListView.builder(
                          itemCount: displayedExpenses.length,
                          itemBuilder: (context, index) {
                            int reversedIndex =
                                displayedExpenses.length - 1 - index;
                            Expense individualExpense =
                                displayedExpenses[reversedIndex];

                            return MyListTile(
                              title: individualExpense.name,
                              subtitle: formatShortDate(individualExpense.date),
                              trailing: formatAmount(individualExpense.amount),
                              onEditPressed: (context) =>
                                  openEditBox(individualExpense),
                              onDeletePressed: (context) =>
                                  openDeleteBox(individualExpense),
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
            name: nameController.text.isNotEmpty
                ? nameController.text
                : expense.name,
            amount: amountController.text.isNotEmpty
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
