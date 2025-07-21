source ~/gdb/mobius_scripts.py
handle SIGTRAP nostop noprint ignore

skip function Simulation_InstructionCallback
skip -rfu std::_List_iterator<.*>::.*
skip -rfu std::allocator<.*>::.*
skip -rfu std::vector<.*>::.*
skip -rfu VirtualDevice::.*Event
