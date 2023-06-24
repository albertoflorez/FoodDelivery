// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./contratoPedido.sol";
import "./contratoPago.sol";

contract Entrega {

    address public contratoPago;
    address public walletUser;
    address public walletRestaurante;
    address public walletRepartidor;

    enum StateType {
        Activo,
        Inactivo
    }

    StateType public State;

    event StatusEntrega(StateType State);
    event Actores(address walletUser, address walletRestaurante, address walletRepartidor);

    constructor() public {
        State = StateType.Inactivo;
        contratoPago = address(0);
    }

    function activate (address contPago) public {
        contratoPago = contPago;
        State = StateType.Activo;
        emit StatusEntrega(State);
    }

    function actors (string memory usuario, string memory restaurante, string memory repartidor) public {
        walletUser = address(bytes20(bytes(usuario)));
        walletRestaurante = address(bytes20(bytes(restaurante)));
        walletRepartidor = address(bytes20(bytes(repartidor)));
        emit Actores(walletUser, walletRestaurante, walletRepartidor);
    }

    function showuser() view public returns(uint) {
        return walletUser.balance;
    }
    function showRest() view public returns(uint) {
        return walletRestaurante.balance;
    }
    function showDel() view public returns(uint) {
        return walletRepartidor.balance;
    }

    function consummation(address contPedido) public {
        Pedido miPedido = Pedido(contPedido);
        uint pedState = miPedido.getState();
        require(pedState == 2, "Aun no se ha entregado el pedido.");
        State = StateType.Inactivo;
        emit StatusEntrega(State);
        activatePago();
    }

    function activatePago() private {
        Pago miPago = Pago(contratoPago);
        miPago.activate(walletUser, walletRestaurante, walletRepartidor);
    }
}