import 'package:hive_ce/hive_ce.dart';
import 'package:ldte_stei_itb/core/model.dart';

@GenerateAdapters([AdapterSpec<MataKuliahPraktikumModel>(), AdapterSpec<StorageCacheModel>(), AdapterSpec<GlobalConfigModel>(), AdapterSpec<UserPreferenceModel>()])
part 'hive_adapters.g.dart';