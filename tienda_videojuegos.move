module tienda_videojuegos::tienda {
    use std::string::{String, utf8, append};
    use sui::vec_map::{Self, VecMap};

    // --- ESTRUCTURAS PRINCIPALES ---
    public struct Tienda has key, store {
        id: UID,
        nombre: String,
        registro_clientes: VecMap<u16, Cliente>
    }

    public struct Cliente has store, drop, copy {
        nombre_cliente: String,
        correo: String,
        ano_registro: u8,
        nivel: Nivel,
        lista_juegos: vector<String>
    }

    public enum Nivel has store, drop, copy {
        cobre(Cobre),
        plata(Plata),
        oro(Oro),
        diamante(Diamante)
    }

    public struct Cobre has store, drop, copy { descuento: u8 }
    public struct Plata has store, drop, copy { descuento: u8 }
    public struct Oro has store, drop, copy { descuento: u8 }
    public struct Diamante has store, drop, copy { descuento: u8 }

    // --- CONSTANTES DE ERROR ---
    #[error]
    const ID_EXISTE: vector<u8> = b"ERROR: el ID ya existe";
    #[error]
    const ID_NO_EXISTE: vector<u8> = b"ERROR: el ID no existe";

    // --- FUNCIONES PRINCIPALES ---
    public fun crear_tienda(nombre: String, ctx: &mut TxContext) {
        let tienda = Tienda {
            id: object::new(ctx),
            nombre,
            registro_clientes: vec_map::empty()
        };
        transfer::transfer(tienda, tx_context::sender(ctx));
    }

    public fun agregar_cliente(
        tienda: &mut Tienda,
        nombre_cliente: String,
        correo: String,
        ano_registro: u8,
        id_cliente: u16
    ) {
        assert!(!tienda.registro_clientes.contains(&id_cliente), ID_EXISTE);

        let cliente = Cliente {
            nombre_cliente,
            correo,
            ano_registro,
            nivel: Nivel::cobre(Cobre { descuento: 5 }),
            lista_juegos: vector[]
        };
        tienda.registro_clientes.insert(id_cliente, cliente);
    }

    public fun agregar_juego(tienda: &mut Tienda, id_cliente: u16, juego: String) {
        assert!(tienda.registro_clientes.contains(&id_cliente), ID_NO_EXISTE);
        let cliente = tienda.registro_clientes.get_mut(&id_cliente);
        cliente.lista_juegos.push_back(juego);
    }

    public fun eliminar_cliente(tienda: &mut Tienda, id_cliente: u16) {
        assert!(tienda.registro_clientes.contains(&id_cliente), ID_NO_EXISTE);
        tienda.registro_clientes.remove(&id_cliente);
    }

    // --- FUNCIONES PARA CAMBIAR NIVELES ---
    public fun cambiar_nivel_cobre(tienda: &mut Tienda, id_cliente: u16) {
        assert!(tienda.registro_clientes.contains(&id_cliente), ID_NO_EXISTE);
        let cliente = tienda.registro_clientes.get_mut(&id_cliente);
        cliente.nivel = Nivel::cobre(Cobre { descuento: 5 });
    }

    public fun cambiar_nivel_plata(tienda: &mut Tienda, id_cliente: u16) {
        assert!(tienda.registro_clientes.contains(&id_cliente), ID_NO_EXISTE);
        let cliente = tienda.registro_clientes.get_mut(&id_cliente);
        cliente.nivel = Nivel::plata(Plata { descuento: 10 });
    }

    public fun cambiar_nivel_oro(tienda: &mut Tienda, id_cliente: u16) {
        assert!(tienda.registro_clientes.contains(&id_cliente), ID_NO_EXISTE);
        let cliente = tienda.registro_clientes.get_mut(&id_cliente);
        cliente.nivel = Nivel::oro(Oro { descuento: 15 });
    }

    public fun cambiar_nivel_diamante(tienda: &mut Tienda, id_cliente: u16) {
        assert!(tienda.registro_clientes.contains(&id_cliente), ID_NO_EXISTE);
        let cliente = tienda.registro_clientes.get_mut(&id_cliente);
        cliente.nivel = Nivel::diamante(Diamante { descuento: 20 });
    }

    // --- FUNCION PARA APLICAR DESCUENTO ---
    public fun aplicar_descuento(tienda: &mut Tienda, id_cliente: u16): String {
        assert!(tienda.registro_clientes.contains(&id_cliente), ID_NO_EXISTE);
        let cliente = tienda.registro_clientes.get_mut(&id_cliente);
        let mut mensaje = utf8(b"Descuento aplicado del: ");

        match(cliente.nivel) {
            Nivel::cobre(d) => { mensaje.append(d.descuento.to_string()); mensaje.