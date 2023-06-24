// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./contratoEntrega.sol";
import "./contratoPago.sol";

contract Pedido {
    address public contratoEntrega;
    address public contratoPago;

    enum StateType {
          Generado,
          Preparando,
          Entregado,
          Terminado,
          Compensado,
          Indefinido
    }

    StateType public State;

    event StatusPedido(StateType State, address contratoEntrega, address contratoPago);

    constructor() public payable  {
        State = StateType.Indefinido;
        contratoEntrega = address(0);
        contratoPago = address(0);
    }

    function updateEstado(uint  estado, address contEntrega, address contPago) public {
        if (contEntrega == address(0)){
            contEntrega = contratoEntrega;
        }
        if (contPago == address(0)){
            contPago = contratoPago;
        }
        if (estado == 1 || estado == 2){
            require(contEntrega != address(0));
            Entrega miEntrega = Entrega(contEntrega);
            if (estado == 1){
                State = StateType.Preparando;
                miEntrega.activate(contPago);
            }
            if (estado == 2){
                State = StateType.Entregado;
                miEntrega.consummation(address(this));
            }
        }
        if (estado == 0){
            State = StateType.Generado;
            contratoPago = contPago;
            contratoEntrega = contEntrega;
        }
        if (estado == 3){
            State = StateType.Terminado;
        }
        if (estado == 4){
            State = StateType.Compensado;
        }
        emit StatusPedido(State, contEntrega, contPago);
    }

    function getState() public returns(uint){
        uint result;
        if (State == StateType.Generado) {
            result = 0;
        }
        if (State == StateType.Preparando) {
            result = 1;
        }
        if (State == StateType.Entregado) {
            result = 2;
        }
        if (State == StateType.Terminado) {
            result = 3;
        }
        if (State == StateType.Compensado) {
            result = 4;
        }
        if (State == StateType.Indefinido) {
            result = 5;
        }
        return result;
    }

    function deposit() public payable {}

    function resolutionPedido(uint resolution, address contCompensacion) public {
        require(State == StateType.Entregado, "Aun no se ha entregado el pedido. Como puede saber como ha ido?");
        payEther(resolution, contCompensacion);
    }

    function payEther(uint resolution, address contCompensacion) private {
        uint amount = address(this).balance;
        Pago miPago = Pago(contratoPago);
        miPago.deposit{value: amount}();
        miPago.decideWhotoPay(address(this), resolution, contCompensacion);
    }
}