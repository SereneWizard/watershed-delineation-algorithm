function[pits] = pit_ider_recurs(flow_dir, pits, pit_id, el_pits)
neighbor = zeros(8,1);
col = size(pits,1); %number of cells in a column for linear indexing below
%The neighbor numbering below has been redefined from the previous flow
%direction function such that position 5 is now position 1. Because it is
%desired to determine whether the neighbor is pointing toward the target
%cell (rather than 180 degrees away), neighboring cell of index n can be
%checked if it contains a value == n in the loop below.
neighbor(5) = (el_pits + col); 
neighbor(6) = (el_pits + col + 1);
neighbor(7) = (el_pits + 1);
neighbor(8) = (el_pits - col + 1);
neighbor(1) = (el_pits - col);
neighbor(2) = (el_pits - col - 1);
neighbor(3) = (el_pits - 1);
neighbor(4) = (el_pits + col - 1);
pits(el_pits) = pit_id;

for n = 1:8
    if flow_dir(neighbor(n)) == n % || flow_dir(neighbor(n_pit_el)) == 0 %if the neighbor is pointing to the target cell or it is 0(indicating a flat pit bottom several cells wide)
        pits = pit_ider_recurs(flow_dir, pits, pit_id, neighbor(n)); % call recursive IDing function
    end
end