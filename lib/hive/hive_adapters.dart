import 'package:hive_ce/hive_ce.dart';
import 'package:eform_ldte/core/model.dart';

@GenerateAdapters([AdapterSpec<MatprakModel>(), AdapterSpec<StorageCacheModel>(), AdapterSpec<GlobalConfigModel>(), AdapterSpec<UserPreferenceModel>(), AdapterSpec<FakultasModel>(), AdapterSpec<ProgramStudiModel>()])
part 'hive_adapters.g.dart';