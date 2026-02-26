package Services {
  private import TransactionalObjects::*;

  part def ManejoCorrales {
    // Aqui iría el Corral + los campos calculados "numeroAves".
  }

  part def ManejoGalpones {}

  part def LimpiezaDesinfeccion {
    action def CleaningAndDesinfection {
      inout galpon : GalponTransactional;

      // The service sends the signal to the shed to trigger the transition
      send new LimpiezaSignal() to galpon;
    }
  }

  part def RecepcionAvicola {}
}
