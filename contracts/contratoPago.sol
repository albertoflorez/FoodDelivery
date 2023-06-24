// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./contratoPedido.sol";
import "./contratoCompensacion.sol";

contract Pago {

    address public user;
    address public restaurant;
    address public deliver;

    enum StateType {
        Activo,
        Inactivo
    }

    StateType public State;

    event StatusPago(StateType State, address walletUser, address walletRestaurante, address walletRepartidor, uint TransaccionRealizada);

    constructor() public payable {
        State = StateType.Inactivo;
    }

    function activate(address usuario, address restaurante, address repartidor) public {
        State = StateType.Activo;
        user = usuario;
        restaurant = restaurante;
        deliver = repartidor;
        emit StatusPago(State, user, restaurant, deliver, 2);
    }

    function deposit() public payable {}

    function decideWhotoPay(address contPedido, uint resolution, address contCompensacion) public {
        Pedido miPedido = Pedido(contPedido);
        uint pedState = miPedido.getState();
        require(pedState == 2, "Aun no se ha entregado el pedido.");
        if (resolution == 1) {
            uint amountRest = address(this).balance * 90 / 100;
            uint amountDeliver = address(this).balance * 10 / 100;
            (bool sentR, bytes memory dataR) = restaurant.call{value: amountRest}("");
            require(sentR, "Failed to send Ether to restaurant");
            (bool sentD, bytes memory dataD) = deliver.call{value: amountDeliver}("");
            require(sentD, "Failed to send Ether to delivery");
            miPedido.updateEstado(3, address(0), address(0));
        }
        if (resolution == 0) {
            uint amount = address(this).balance;
            Compensacion miCompensacion = Compensacion(contCompensacion);
            miCompensacion.deposit{value: amount}();
            miCompensacion.compensar(user);
            miPedido.updateEstado(4, address(0), address(0));
        }
        State = StateType.Inactivo;
        emit StatusPago(State, user, restaurant, deliver, resolution);
    }
}