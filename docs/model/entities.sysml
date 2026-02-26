/* - Las entidades son items y los servicios son parts.
 *    - Son items porque en nuestro sistema se manejan como objetos que se crean, modifican y eliminan, y se mueven entre servicios.
 *    - Son parts porque son componentes de la estructura del sistema y tienen comportamiento asociado a través de acciones. También tienen interfaces, puertos y hablan con otros servicios.
 * - Las relaciones entre entidades se modelan con connections.
 */

package Entities {
  private import ScalarValues::*;
  private import ISQ::*;
  private import StringFunctions::*;
  private import Library::*;

  enum def ZonaGeografica {
    doc
    /* Ejemplos de Zonas Geograficas. */
    // NOTA: Puede que en lugar de ser un 'enum' sea un 'item' con su servicio de manejo.
    CampoNorte;
    CostaVerde;
    ColinaCentral;
  }

  enum def TiposGranjaTecno {
    AmbienteControlado;
    SemiAutomatizado;
    Tradicional;
  }

  enum def TiposGranjaAvicola {
    Engorde;
    PosturaComercial;
    CriaYLevante;
    Reproductora;
  }

  item def Persona {
    /* Maybe should be Empleado or other specialization */
    /* Probably add attrs about it like id */
  }

  item def SociedadFI {
    /* Primary Key */
    attribute codigo : NumericCode { :>> lenght = 4; }

    /* Relationships */
    item centrosLogisticos : CentroLogistico [0..*];
  }

  connection def SociedadCentroLogisticoRelationship {
    doc
    /* Una sociedad FI puede tener varios centros logísticos, pero un centro logístico solo puede pertenecer a una sociedad FI. */
    end sociedadFI : SociedadFI crosses centroLogistico.sociedadFI;
    end centroLogistico : CentroLogistico crosses sociedadFI.centrosLogisticos;
  }

  item def CentroLogistico {
    /* Primary Key */
    attribute codigo : NumericCode { :>> lenght = 4; }

    /* Relationships */
    ref item sociedadFI : SociedadFI;
    item almacenes : Almacen [0..*];
  }

  connection def CentroLogisticoAlmacenRelationship {
    doc
    /* Un centro logístico puede tener varios almacenes, pero un almacén solo puede pertenecer a un centro logístico. */
    end centroLogistico : CentroLogistico crosses almacen.centroLogistico;
    end almacen : Almacen crosses centroLogistico.almacenes;
  }

  item def Almacen {
    /* Primary Key */
    attribute codigo : NumericCode { :>> lenght = 4; }

    /* Relationships */
    ref item centroLogistico : CentroLogistico;
  }

  attribute def NumeroAves :> Natural;

  item def Granja {
    /* Primary Key */
    attribute id : UUID;

    /* Uniq Constraint */
    ref item centroLogistico : CentroLogistico;

    /* Required Properties */
    attribute descripcion : String;
    attribute direccion : String;
    attribute coordenadas : GeoCoordinate;
    attribute zonaGeografica : ZonaGeografica;
    attribute dimensiones : HectareValue;
    attribute capacidadInstalada : NumeroAves;
    attribute capacidadReal : NumeroAves;
    attribute tipoGranjaTecno : TiposGranjaTecno;
    attribute tipoGranjaAvicola : TiposGranjaAvicola;

    /* Relationships */
    item responsable : Persona;
    item silos : Silo [0..*];
    item galpones : Galpon [0..*];
  }

  connection def GranjaGalponRelationship {
    doc
    /* Una granja puede tener varios galpones, pero un galpón solo puede pertenecer a una granja. */
    end granja : Granja crosses galpon.granja;
    end galpon : Galpon crosses granja.galpones;
  }

  connection def GranjaSiloRelationship {
    doc
    /* Una granja puede tener varios silos, pero un silo solo puede pertenecer a una granja. */
    end granja : Granja crosses silo.granja;
    end silo : Silo crosses granja.silos;
  }

  item def Silo {
    /* Primary Key */
    attribute id : UUID;

    /* Uniq Constraint */
    ref item almacen : Almacen;

    /* Required Properties */
    attribute capacidad : TonneMassValue;

    /* Relationships */
    ref item granja : Granja;
    ref item galpones : Galpon [0..*];
  }

  item def Galpon {
    /* Primary Key */
    attribute id : UUID;

    /* Uniq Constraint */
    ref item almacen : Almacen;

    /* Required Properties */
    item responsable : Persona;
    attribute dimensiones : AreaValue;

    /* Relationships */
    ref item granja : Granja;
    ref item silo : Silo;
    item corral : Corral [1..*];
  }

  connection def GalponSiloRelationship {
    doc
    /* Un silo alimenta a varios galpones, pero un galpón solo puede ser alimentado por un silo. */
    end galpon : Galpon crosses silo.galpones;
    end silo : Silo crosses galpon.silo;
  }

  connection def GalponCorralRelationship {
    doc
    /* Un galpón puede tener varios corrales, pero un corral solo puede pertenecer a un galpón. */
    end galpon : Galpon crosses corral.galpon;
    end corral : Corral crosses galpon.corral;
  }

  item def Corral {
    /* Primary Key */
    attribute id : UUID;

    /* Relationships */
    ref item galpon : Galpon;
    ref item lote : Lote;
  }

  item def Lote {
    /* Primary Key */
    attribute codigo : FormattedCode {
      doc
      /* \\ is used here to escape the backslash character, but in the actual regex pattern it will be a single backslash */
      :>> pattern = "^[A-Z]-\\d{4}"; // NOTE: En SAP son 10 caracteres libres.
    }

    /* Required Properties */

    /* Relationships */
    ref item corral : Corral;
  }
}

package TransactionalObjects {
  private import Library::*;
  private import Entities::*;
  private import ISQ::*;

  item def LimpiezaSignal;

  state def ShedLifecycle {
    entry;
    then Unready;

    state Unready;
    state Ready;

    transition ToReadyByLimpieza first Unready accept LimpiezaSignal then Ready;
  }

  // NOTA: Should this be a new item or should it be a specialization?
  item def GalponTransactional {
    /* Primary Key */
    attribute id : UUID;

    /* Uniq Constraint */
    ref item galpon : Galpon;
    attribute fecha : ISQ::TimeValue; // TODO: maybe specify format

    /* States */
    exhibit state lifecycle : ShedLifecycle;
  }

  // NOTA: Should this be a new item or should it be a specialization?
  item def CorralTransactional {
    /* Primary Key */
    attribute id : UUID;

    /* Uniq Constraint */
    ref item corral : Corral;
    attribute fecha : ISQ::TimeValue; // TODO: maybe specify format

    // TODO: How to do the following:
    // attribute numeroAves : ScalarValues::Integer; // Campo calculado a partir del lote
  }
}
