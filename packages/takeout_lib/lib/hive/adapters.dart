import 'package:hive_ce/hive.dart';
import 'package:takeout_lib/listen/model.dart';

part 'adapters.g.dart';

@GenerateAdapters([AdapterSpec<Listen>()])
// Annotations must be on some element
// ignore: unused_element
void _() {}
