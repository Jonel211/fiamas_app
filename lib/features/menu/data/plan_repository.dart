import '../../auth/data/models/tendero_model.dart';

class PlanRepository {
  const PlanRepository(this.tendero);

  final TenderoModel? tendero;

  bool get isPremium => tendero?.isPremium ?? false;
}
