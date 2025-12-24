import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class ExpenseDatabase extends ChangeNotifier {
  static late Isar isar;
  List<Expense> _allExpense = [];

  /*

  S E T U P

  */

  //INITIALLIZE db
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([ExpenseSchema], directory: dir.path);
  }

  /*

  G E T T I N G S

  */

  List<Expense> get allExpense => _allExpense;

  /*

  O P E R A T I O N S

  */

  // CREATE - add a new expense
  Future<void> createNewExpense(Expense newExpense) async {
    //add to db
    await isar.writeTxn(() => isar.expenses.put(newExpense));

    // re-read from db
    await readExpense();
  }

  // READ - expenses from db
  Future<void> readExpense() async {
    //fetch al existing expense from db
    List<Expense> fetchedExpenses = await isar.expenses.where().findAll();

    //give to local expense list
    _allExpense.clear();
    _allExpense.addAll(fetchedExpenses);

    //update UI
    notifyListeners();
  }

  // UPDATE - edit an expense from a db
  Future<void> updateExxpense(int id, Expense updateExpense) async {
    // make sure new expense has id as exisiting one
    updateExpense.id = id;

    //update in db
    await isar.writeTxn(() => isar.expenses.put(updateExpense));

    //re-read - an expense
    await readExpense();
  }

  // DELETE - an expense
  Future<void> deleteExpense(int id) async {
    //delete from db
    await isar.writeTxn(() => isar.expenses.delete(id));

    //re-read from db
    await readExpense();
  }

  /*

   H E L P E R S

  */

  //calculate total expenses for each month
  /*
  year - month

  (
    2024-0: $250, jan
    2024-1: $200, feb
    2024-2: $175, mar
  )
  
  */
  Future<Map<String, double>> calculateMonthlyTotals() async {
    //ensure the expense are read from the db
    await readExpense();

    //create a map to keep track of total expense per month, year
    Map<String, double> monthlyTotals = {};

    //iterate over all expenses
    for (var expense in _allExpense) {
      //extract the year and month from the date of the expense
      String yearMonth = '${expense.date.year}-${expense.date.month}';

      //if the year and month is not yeet in the map, initialize to 0
      if (!monthlyTotals.containsKey(yearMonth)) {
        monthlyTotals[yearMonth] = 0;
      }

      //add the expense amount to the total for the month
      monthlyTotals[yearMonth] = monthlyTotals[yearMonth]! + expense.amount;
    }
    return monthlyTotals;
  }

  // calculate currrent month total
  Future<double> calculateCurrentMonthTotal() async {
    // ensure expenses are made from the db first
    await readExpense();

    //get current month, year
    int currentMonth = DateTime.now().month;
    int currentYear = DateTime.now().year;

    //filter the expense to include only for this month this year
    List<Expense> currentMonthExpenses =
        _allExpense.where((expense) {
          return expense.date.month == currentMonth &&
              expense.date.year == currentYear;
        }).toList();
    // calculate total amount for the current month
    double total = currentMonthExpenses.fold(
      0,
      (sum, expense) => sum + expense.amount,
    );
    return total;
  }

  // get start month
  int getStartMonth() {
    if (_allExpense.isEmpty) {
      return DateTime.now()
          .month; // default to current month is no expenses are recorded
    }
    //sort  expenses by date to find the earliest
    _allExpense.sort((a, b) => a.date.compareTo(b.date));
    return _allExpense.first.date.month;
  }

  // get start year
  int getStartYear() {
    if (_allExpense.isEmpty) {
      return DateTime.now()
          .year; // default to current month is no expenses are recorded
    }
    //sort  expenses by date to find the earliest
    _allExpense.sort((a, b) => a.date.compareTo(b.date));
    return _allExpense.first.date.year;
  }
}
