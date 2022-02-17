// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;
import "./SafeMath.sol";

// Interface de nuestro token
interface IERC20 {
    // Devuelve la cantidad de tokens en existencia
    function totalSupply() external view returns (uint256);

    // Devuelve la cantidad de tokens para una direccion indicada por parametro
    function balanceOf(address account) external view returns (uint256);

    // Devuelve el numero de tokens que el spender podra gastar en nombre del propietario (owner)
    function allowance(address owner, address spender) external view returns (uint256);

    // Devolver valor booleano resultaod de la operacion indicada
    function transfer(address recipient, uint256 amount) external returns (bool);

    // Devuelve un valor booleano con el resultado de la operacion de gasto
    function approve(address spender, uint256 amount) external returns (bool);

    // Devuelve un valor booleando con el resultado de la operacion de paso de una cantidad de tokens usando el metodo allowance()
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    // Evento que se debe emitir cuando una cantidad de tokens pase de un origen a un destino
    event Transfer(address indexed from, address indexed to, uint256 amount);
    
    // Evento que se debe emitir cuando se establece una asignacion con el metodo allowance
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// Implementacion de las funciones del token ERC20
contract ERC20Basic is IERC20 {

    // Informacion basica del token
    string public constant name = "Tuertocoin";
    string public constant symbol = "DSC";
    uint8 public constant decimals = 2;

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed owner, address indexed spender, uint256 tokens);

    using SafeMath for uint256;
    
    // Mapping para guardar balances
    mapping (address => uint) balances;
    // Mapping que conecta quien minó las monedas con los posteriores propietarios
    mapping (address => mapping (address => uint)) allowed;

    // Set total supply
    uint256 totalSupply_;

    constructor (uint256 initialSupply) public {
        totalSupply_ = initialSupply;
        balances[msg.sender] = totalSupply_;
    }

    function totalSupply() public override view returns (uint256) {
        return totalSupply_;
    }

    // Funcion para minar nunevos tokens
    function increaseTotalSupply(uint newTokensAmount) public {
        totalSupply_ += newTokensAmount;
        balances[msg.sender] += newTokensAmount;
    }

    function balanceOf(address tokenOwner) public override view returns (uint256) {
        return balances[tokenOwner];
    }

    function allowance(address owner, address delegate) public override view returns (uint256) {
        return allowed[owner][delegate];
    }

    function transfer(address recipient, uint256 numTokens) public override returns (bool) {
        // Chequear si quien quiere transferir tiene disponibles los tokens
        require(numTokens <= balances[msg.sender]);

        // Hacer la transferencia
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[recipient] = balances[recipient].add(numTokens);

        // Emitir evento
        emit Transfer(msg.sender, recipient, numTokens);
    }

    // Dar permiso a alguien para gastar mis tokens
    function approve(address delegate, uint256 numTokens) public override returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    // Un delegado transfiera tokens desde un propietario a un nuevo propietario 
    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool) {
        
        // Verificar que el propietario tiene los tokens
        require(numTokens <= balances[owner]);

        // Verificar que el delegador tiene el permiso de delegacion
        require(numTokens <= allowed[owner][msg.sender]);

        // Cambiar balances
        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);

        // Emitir evento
        emit Transfer(owner, buyer, numTokens);
        return true;
    }

}