#[starknet::interface]
pub trait IERC20<TContractState> {
    fn name(self: @TContractState) -> felt252;
    fn symbol(self: @TContractState) -> felt252;
    fn totalSupply(self: @TContractState) -> felt252;
    fn balanceOf(self: @TContractState, account: starknet::ContractAddress) -> felt252;
    fn transfer(ref self: TContractState, recipient: starknet::ContractAddress, amount: felt252);
    fn transferFrom(
        ref self: TContractState,
        sender: starknet::ContractAddress,
        recipient: starknet::ContractAddress,
        amount: felt252,
    );
}

