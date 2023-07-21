% Task 1.
/*
 * add(X, Y, Z, Cnf), will encode a CNF for X + Y = Z
 * X, Y and Z are natural numbers in bit vector notation.
 * Z should be 1 bit longer then max(lengt(X), length(Y)).
 * We will use an auxilary predicate to help with the task.
 */


/*
 * add_aux(X, Y, Z, Cin, Cnf), will be used to add the CNF clauses to Cnf while passing the Carry to the next step. 
 * The predicate will iterate over X and Y together, each iteration will add a cnf clause for Z and the carry Cin. 	 
 * We will use the auxilary predicate to pass the "Cnf linked" Cout as the Cin of the next bit starting from the LSB of X and Y.
 */

% Base cases for end of X and Y
add_aux([],[], [Cin], Cin, []).

% Case for end of Y but X has more bits.
add_aux([X | Xs], [], [Z | Zs], Cin, Cnf):-
    add_aux([X | Xs], [-1], [Z | Zs], Cin, Cnf).	% recursive call with Y as [-1], to calculate Cin + X

% Case for end of X but Y has more bits.
add_aux([], [Y | Ys], [Z | Zs], Cin, Cnf):-
    add_aux([-1], [Y | Ys], [Z | Zs], Cin, Cnf).	% recursive call with X as [-1], to calculate Cin + Y

add_aux([X | Xs], [Y | Ys], [Z | Zs], Cin, Cnf):-
    % Cnf0 will be the CNF clause of each iteration.
    Cnf0 = [[-Z, X, Y, Cin], [Z, X, Y, -Cin], [Z, X, -Y, Cin], [-Z, X, -Y, -Cin],			% Clauses for the current bit of Z, X, Y and Cin
	    [Z, -X, Y, Cin], [-Z,-X, Y, -Cin] , [-Z,-X, -Y, Cin], [Z, -X, -Y, -Cin],		
    	    [-Cout, X, Y, Cin], [-Cout, X, Y, -Cin], [-Cout, X, -Y, Cin], [Cout, X, -Y, -Cin],		% Clauses for Cout to pass.
	    [-Cout, -X, Y, Cin], [Cout, -X, Y, -Cin], [Cout, -X, -Y, Cin], [Cout, -X, -Y, -Cin]],	% Clauses were taken from the "false table"
    add_aux(Xs, Ys, Zs, Cout, Cnf1),									% Recursive call with the "linked" Cout
    append(Cnf0, Cnf1, Cnf).										% appending all the recursive calls Cnfs




add(X, Y, Z, Cnf):-
    add_aux(X, Y, Z, -1, Cnf), !.		% Starting Cin is -1 (0).




%Task 2.
/*
 * lt(X, Y, Cnf), will encode a CNF for X < Y.
 * leq(X, Y, Cnf), will encode a CNF for X <= Y.
 * X and Y are natural numbers in bit vector notation.
 * We will use an auxilary predicate to help with both lt and leq
 */


/*
 * less_aux(X, Y, B, Cnf), will be used to encode the CNF clauses to Cnf.
 * B indicates if in the previous iteration the bit of X = the bit of Y
 * The predicate will iterate over X and Y together, each iteration will add a CNF clause for B, B1(the "B" of the next iteration), X, Y	 
 */
less_aux([X | Xs], [Y |Ys], B, Cnf):-
    Cnf0 = [[-B, B1], [-B, -X, Y], [-B, X, -Y],[B, -B1, -X], [B, -B1, Y]],	% If X != Y, B = flase, so B1 must be true, which will force Y>X
    less_aux(Xs, Ys, B1, Cnf1),
	append(Cnf0, Cnf1, Cnf).

% Base case for reaching end of X and Y
less_aux([], [], B, [[B]]).	% B must be true, forcing all previous B to either be true ( Y = X )  or false so Y > X

% Base case for reachign end of X but Y has more bits
less_aux([], [Y | Ys], B , Cnf):-
    less_aux([-1], [Y | Ys], B, Cnf).

% Base case for reachign end of Y but X has more bits
less_aux([X | Xs], [], B, Cnf):-
    less_aux([X | Xs], [-1], B, Cnf).



% No restrictions on B allows numbers to be equal as well as Y > X
leq(Xs, Ys, Cnf) :-
    less_aux(Xs, Ys, _, Cnf), !.

% the -B will force Y > X
lt(Xs, Ys, [[-B] | Cnf]) :-
    less_aux(Xs, Ys, B, Cnf), !.





%Task 3.
/*
 * sum(List, Z, Cnf), will encode a CNF for the sum of the binary vectors in the list List such that their sum = Z.
 * Z and all the numbers in the list are in binary vector notation.
 * Z should be the length of the highest length number in list + the length of the list - 1.
 * We will use an auxilary predicate to help with the task.
 */


/*
 * sum_aux(List, Sum, Z, Cnf), will be used to encode the CNF clauses to Cnf, while "remembering" the added value so far.
 * Sum is the value of the added numbers in the list so far.
 * The predicate will iterate over the List, each iteration will encode a CNF clause for Numb + Sum ( the current number + the sum so far ).	 
 */

% Base case for end of the list, Zs = Sum
sum_aux([], Sum, Sum, []).
	

sum_aux([Numb | ListOfNumbers], Sum, Zs, Cnf):-
    add(Numb, Sum, Sum1, Cnf0),				% Add the current number to Sum
    sum_aux(ListOfNumbers, Sum1, Zs, Cnf1),		% Recursive call for next number with the new Sum
    append(Cnf0, Cnf1, Cnf).		




sum([Numb | ListOfNumbers], Zs, Cnf) :-
    sum_aux(ListOfNumbers, Numb, Zs, Cnf).		% first Sum should be the first numb to save an addition of 0.





%Task 4.
/*
 * times(List, Z, Cnf), will encode a CNF for X * Y = Z.
 * Z, X, Y are numbers in binary vector notation.
 * Z should be the length of length(X) + length(Y)
 * we will use long multiplication, the predicate will iterate X for each "bit" in Y creating a List of K
 * each K is the result of X times a bit in Y.
 * at the end of the iteration over Y the predicate will sum the K's which should be equal to Z  
 * We will use 2 auxilary predicate to help with the task.
 */


/*
 * times_loop(X, Y, K, Cnf), will encode a CNF for the multiplication of X and a bit of Y
 * Iterates the Xs with a bit Y to encode a CNF for X * Y = K
 */

% Base case for end of X.
times_loop([], _, [], []).


times_loop([X | Xs], Y , [S | Ks], Cnf):-
    Cnf0 = [[-S,X, Y],[-S, -X, Y], [-S, X, -Y], [S, -X, -Y]],		% CNF from false table of X*Y
    times_loop(Xs, Y, Ks,  Cnf1),					% Recursive call for the next X in Xs
    append(Cnf0, Cnf1, Cnf).				


/*
 * times_aux(X, Y, Z, List, Shift, Cnf), will create a list of the K's needed to sum, while keeping track of how many shiftfs needed for X
 * Iterates over Y and the List while using time_loop to encode the multiplcation of X and current Y = K
 * Each iteration will append X with Shift to create the shifted X for multiplaction of X and bit Y
 */

% Base case for end of Y
times_aux(_, [], _, [],_, _).


times_aux(Xs, [Y | Ys], Zs, [Ks | List], Shift, Cnf) :-
    times_loop(Xs, Y, Ts, Cnf0),					% using times_loop to encode the Cnf for Xs * Y = TS
    append(Shift, Ts, Ks),						% shifting the result TS to the right amount
    times_aux(Xs, Ys, Zs, List, [-1 | Shift], Cnf1),			% Recursive call with a "new" Shift, rest of Y and rest of List
    append(Cnf0, Cnf1, Cnf).
	

times(Xs, Ys, Zs, Cnf):-
    times_aux(Xs, Ys, Zs, List,[], Cnf0),				% "Creating" List and the cnf for the K's in it
    sum(List, Zs, Cnf1),						% Sum of List = Zs
    append(Cnf0, Cnf1, Cnf), !.





%Task 5.
/*
 * power(N, X, Z, Cnf), will encode a CNF for X^N = Z
 * X, Y are numbers in binary vector notation.
 * N is a natural number.
 * Z should be the length of N * length(X).
 * The predicate will use times(Sum, X, NewSum) N times to encode the CNF.    
 * We will use an auxilary predicate to help with the task.
 */


/*
 * power_aux(N, X, Z, Sum, Cnf), will encode the CNF while of Sum * X "remembering" the sum so far.
 * Will be preformed N-1 times, where sum is initiallised as X.
 */

% Base case for powers of 0.
power_aux(0, _, [1], _, []).

% Base case for powers of 1.
power_aux(1, _, Sum, Sum, []).

power_aux(N , Xs, Zs, Sum, Cnf):-
    N > 1,				
    times(Sum, Xs, NewSum, Cnf0),	 % encode Sum * X = NewSum
    M is N - 1,				 % Decrement N
    power_aux(M, Xs, Zs, NewSum, Cnf1),  % Recursive call with the new Sum and decremented N (M).
    append(Cnf0, Cnf1, Cnf), !.



power(N, X, Z, Cnf) :-
	power_aux(N, X, Z, X, Cnf).	% Initiallising Sum as X.




%Task 6.
/*
 * powerEquation(N, M, Zs, List, Cnf), given positive numbers N, M and a bit vector Zs,
 * will generate a list List = [As1,..., Asm] and a Cnf which is satisfied when Zs^N = As1^N +...+ Asm^N.
 * we will use 2 auxilary predicates to help with the task.
*/

/*
 * zeroes(Size, List), will generate a List of size Size filled with -1
 * Size is a natural number
 */

% Base case for 0, empty list
zeroes(0, []).

zeroes(Size, [-1 | List]) :-		% Element in List is -1
    Size > 0,
    NewSize is (Size - 1),		% Decrement Size
    zeroes(NewSize, List).



/*
 * powerEquation_aux(N, M, Zs, List, PowList, Length, Cnf)
 * We will use this auxilary predicate to create a new list PowList in which will be all the elements in List to the power of N.
 * Length will be used to remember the length of Zs so that all numbers in List are of the same length.
 */

% Reaching the end of the List ( List should hold M binary numbers ).
powerEquation_aux(N, M, Zs, [], PowList, _, Cnf) :-
    power(N, Zs, Ans, Cnf0),		% Get Zs^N to Ans and keep the Cnf for it
    AddedZeroes is (M - 1),		% Need to pad with zeroes to fit sum
    zeroes(AddedZeroes, List),		% Create List with  M - 1 zeroes
    append(Ans, List, Ans1),		% append the zeroes to the ans ( power of Zs )
    sum(PowList, Ans1, Cnf1),		% get Cnf so sum of PowList = Ans1
    append(Cnf0, Cnf1, Cnf).
    
    
powerEquation_aux(N, M, Zs, [Xs | List], PowList, Length, Cnf) :-
    length(Xs, Length),								% Set number in List to same Length as Zs
    power(N, Xs, Ys, Cnf0),							% Get Xs ^ N = Ys Cnf
    powerEquation_aux(N, M, Zs, List, [Ys | PowList], Length, Cnf1),		% Recursive call, Ys is the new number in PowList ( Xs^N )
    append(Cnf0, Cnf1, Cnf), !.
    



powerEquation(N, M, Zs, List, Cnf) :-
    length(Zs, Length),
    length(List, M),					
    powerEquation_aux(N, M, Zs, List, [], Length, Cnf).  	% PowList should be empty at the start, Length is linked with Zs's length.








/*
 ************************************* DISCLAIMER *************************************
 * Some of the predicates will be used for both task 7 and task 8.
 * I could not make my program run at some of the times u published in the tasks.
   It seems like removing some of the Cnf ( making times shorter by 1 clause per iteration ) or removing leq only made things worst.
   Also tried changing the positions of my Cnf, appending in different orders and variations.
   This is the fastest I could get it to run with my limited knowledge of sat solvers.
   My Times and amount of Clauses are as follows :

 * Sat solver used : Glucose v2.2
 * Task 5 : 
	   	Xs=[_,_,_], power(3,Xs,Zs,Cnf) - 492 Cnf Clauses.
 	        Xs=[_,_,_], power(7,Xs,Zs,Cnf) - 3060 Cnf Clauses.
 * Task 7 :
		solve(euler(5,8), Solution) - Time ~ 200 , 68655 Cnf Clauses. 
 * Task 8 :
		solveAll(partition(4,9), Solutions) - Time Unknown - More then 8 hours, 54838 Cnf Clauses.
		solveAll(partition(5,7), Solutions) - Time Unknown - More then 8 hours, 62629 Cnf Clauses.

 * Rest of the test were around the same as the results given in the assignment.
*/



%Task 7.
/*
 * solve(Instance,Solution).
 * Given Instance = euler(N, NumBits) where N is the given power and NumBits is a number of bits,
 * A solution is a list of positive numbers of the form [B, A1, . . . , AN−1] such that B^N = A^1N + · · · AN-1^N, 
 * A1 ≤ A2 ≤ · · · ≤ AN−1, and such that all of the numbers can be represented as bit vectors in NumBits.
 * Each such solution is a counter exampleto the above conjecture. 
 * If there is no solution for a given instance, then the call to solve(Instance,Solution) should fail. 
 * We will use a few predicates to help with the task.
 */


/*
 * noneZeroes(Map, Cnf), will encode a Cnf such that all binary bit vectors in Map are not representing the number 0
 */
noneZeroes([], []).
noneZeroes([Xs | Map], [Xs | Cnf]):-
	noneZeroes(Map, Cnf).


/*
 * encode_Map(N, Length, Map, Last, Cnf), will generate a Map and a Cnf.
 * Map will hold all the binary bit vectors A1,... AN-1
 * The Cnf will be satasfied only if all A1,...AN-1 != 0 and A1 <= A2 <=....<=AN-1
 * The predicate will also "set" the size of each Ai to be Length
 * Last will hold the previous numbers, so that we can add a cnf for current Ai >= Last
 */

% Base case for the end of Map
encode_Map(_, _, [], _, []).

encode_Map(N, Length, [Xs | Map], Last, [Xs | Cnf]) :-		% Set a Cnf for each number Xs != 0 
    length(Xs, Length),						
    encode_Map(N, Length, Map, Xs, Cnf0),		
    leq(Last, Xs, Cnf1),					% Cnf for Xs >= Last
    append(Cnf0, Cnf1, Cnf).
 


/*
 * encode_aux(N, Length, Map, M, Cnf), will be used to set the Zs ( the answer of the equation, B ) 
 * Setting the Zs and A1 to the recieved Length
 * Then calling encode_Map to encode the rest of the numbers in Map
 * And finally encoding the Cnf for B^N = A^1N + · · · AN-1^N ( using powerEquation)
 */   
encode_aux(N, Length, [Zs | [Xs | Map]], M, Cnf) :-
    length(Zs, Length),
    length(Xs, Length),
    encode_Map(N, Length, Map, Xs, Cnf0),		% encode rest of the Map
    powerEquation(N, M, Zs, [Xs | Map], Cnf1),		% get B^N = A^1N + · · · AN-1^N Cnf
    append([Xs | Cnf0], Cnf1, Cnf), !.
 


/*
 * encode(euler(N, Length), Map, Cnf), given an euler Instance, will generate a Map and a Cnf for the task.
 * Simply Setting M to N - 1, setting the length of Map to N ( Z and N-1 Xs ) 
 * Then using encode_aux to do the Map and Cnf Building
 */     
encode(euler(N, Length), Map, Cnf) :-
    M is N - 1,
    length(Map, N),
    encode_aux(N, Length, Map, M, Cnf).

/*
 * encode(parition(N, Length), Map, Cnf), given an parition Instance ( Task 8) , will generate a Map and a Cnf for the task.
 * Simply setting the length of Map to N + 1 ( Z and N Xs ) 
 * Then using encode_aux to do the Map and Cnf Building 
 */
encode(partition(N, Length), Map, Cnf) :-
    M is N + 1,
    length(Map, M),
    encode_aux(N, Length, Map, N, Cnf).




/*
 * binary_To_Decimal(Xs, Ys, Factor, Sum), will succeed if binary vector Xs = Zs in decimal Base
 * Factor will be used to keep track of the factor of 2 for the calculation ( 2^i ).
 * Sum will be used to remember the sum so far. 
 * This predicate will be used as part of verfying the Solution.
 */
% Base case for end of Xs, Ys = Sum.
binary_To_Decimal([], Zs, _, Zs).

% Case for bit in X is 1
binary_To_Decimal([1 | Xs] , Zs, Factor, Sum) :-
    Sum1 is Sum + Factor,			% Sum1 is the sum so far + the factor
    Factor1 is Factor *2,			% set next Factor ( 2^(i+1) )
    binary_To_Decimal(Xs, Zs, Factor1, Sum1).

% Case for bit in X is -1 ( 0 )
binary_To_Decimal([-1 |Xs], Zs, Factor, Sum) :-
    Factor1 is Factor *2,			% only increase the factor
    binary_To_Decimal(Xs, Zs, Factor1, Sum).



/*
 * decode(Map, Solution), given a Map the predicate wil generate a List Solution. 
 * The predicate will iterate over the binary bit vectors in Map.
 * Each iteration will convert the current binary bit vector in map to decimal Ys and set it as the number in Solution
 */
decode([], []).

decode([Xs | Map], [Ys | Solution]) :-		% Set Ys in Solution
    binary_To_Decimal(Xs, Ys, 1, 0),		% Convert Xs to decimal Ys, starting Factor is 1, Sum is 0.
    decode(Map, Solution).




/*
 * verify(euler(N, Length), Solution), given a euler Instance, verify that Solution is a counter example to euler
 * the predicate will set M and use an auxilary predicate to return True if that solution was verfied and false otherwise
 * if the auxilary predicate returned true, print to screen "verified:ok".
 */


/*
 * verify_aux(N, Length, Solution, M), will use verify_rest to verify all the A's.
 * verify_rest(Solution, CurrSum, Sum, N, Length, X, Size) will also calculate A^1N + · · · AM^N
 * verify_rest will keep track of the sum so far as CurrSum, it will also verify A1,...AM != 0, A1 <= A2 <=....<=AM and that length(Solution) = M.
 * then verify_aux will verify the answer of the equation and that B^N = A^1N + · · · AM^N
 */


% Case for Ai > Ai+1
verify_rest([X | _], Sum, Sum, _, _, Last, _) :-
    X < Last, !,
    writeln(X < Last), false.

% Case for X is not of Length bits
verify_rest([X | _], Sum, Sum, _, Length, _, _) :-
    X >= (2 ** Length), !,
    writeln(X : " has too many bits"), false.

% Case for length(Solution) > M
verify_rest([], Sum, Sum, _, _, _, Size) :-
	Size < 0, !,
	writeln("Too many variables"), false.

% Main loop
verify_rest([X | Solution],CurrSum, Sum, N, Length, _, Size) :-
    CurrSum1 is (X ** N) + CurrSum,					% Calculate CurrSum
    Size1 is Size - 1,							% Decrement Size
    verify_rest(Solution, CurrSum1, Sum, N, Length, X, Size1).

% Case for length(Solution) < M
verify_rest([], Sum, Sum, _, _, _, Size) :-
    Size > 0, !,
    writeln("Not enough variables"), false.

% end of verify_rest - verified (returnns true)
verify_rest([], Sum, Sum, _, _, _, 0).




% Case of Z too big ( too many bits )
verify_aux(_, Length, [Z | _], _) :-
    Z >= (2 ** Length), !,
    writeln(Z : " has too many bits"), false.

% Case for false in verfied_rest
verify_aux(N, Length, [_ | Solution], M) :-
    not(verify_rest(Solution, 0, _, N, Length, 0, M)), !,   false.

% Case for B^N != A^1N + · · · AM^N
verify_aux(N, Length, [Z | Solution], M) :-
    verify_rest(Solution, 0, Sum, N, Length, 0, M),
    K is (Z ** N),
    Sum =\= K, !,
    writeln(K =\= Sum), false.

% end of verify_aux - verified ( returns true ).
verify_aux(_, _, _, _).




% Base case for an empty Solution.
verify(_ , []).

% Case for auxilary predicate, returning false.
verify(euler(N, Length), Solution) :-
    M is N - 1,
    not(verify_aux(N, Length, Solution, M)), !.

% Verified.
verify(_, _) :-
    writeln(verified:ok).




solve(Instance, Solution) :-
    encode(Instance, Map, Cnf),
    sat(Cnf),
    decode(Map,Solution),
    verify(Instance, Solution).


%Task 8.
/*
 * solveAll(Instance,Solution).
 * Given Instance = partition(N, NumBits)  where N and NumBits are positive numbers.
 * A solution is a list of lists each of which consists of N + 1 positive numbers of the form 
 * [B, A1, . . . , AN−] such that BN = A1^N + · · · AN^N , A1 ≤ A2 ≤ · · · ≤ AN−1,
 * and such that all of the numbers in the list can be represented as bit vectors in NumBits.
 * Each solution in the list describes a number B with its nth power partition 
 * If there is no solution for a given instance, then the call to solveAll should return Solution = []. 
 * We will use a few predicates to help with the task.
 */



/*
 * row(I, Cols, Rows), trans(Cols,Rows) are predicates learned in class to switch between the colums and rows of a 2D List.
*/
row(I, Cols, Rows) :-
    findall(X, (member(C, Cols), nth1(I, C, X)), Rows).

trans(Cols, Rows) :-
    Cols = [C | _],
    length(C, N),
    findall(Row, (between(1, N, I), row(I, Cols, Row)), Rows).


/*
 * trans_Map(Map ,NewMap), given a map Map, the predicate will switch between the Rows and Colums of each 2D list (Xs) in Map
*/

% Base case for end of Map.
trans_Map([], []).
trans_Map([Xs | Map] , [TXs | NewMap]):-	% Set TXs as a list in NewMap
    trans(Xs, TXs),				% Switch the rows and colums of Xs creating TXs
    trans_Map(Map, NewMap).			% Recursive call on the rest of Map



/*
 * decodeAll(Map, Solutions), given a Map the predicate will generate Solutions
 * We will use an auxilary predicate to help with the task.
*/



/*
 * decodeAll_Loop(Map, Solutions), the predicate will iterate Map to generate a Solution
 * we Will use the predicate decode to decode each solution
*/

% Base case for end of Map
decodeAll_Loop([], []).
decodeAll_Loop([Xs | Map], [Sol | Solutions]) :-	% Set a solution into Solutions ( Sol )
    decode(Xs, Sol),					% Decode the solution
    decodeAll_Loop(Map, Solutions).			% Iterate to the next solution.

decodeAll(Map , Solutions) :-
    trans_Map(Map, TempMap),				% Switching the rows and colums of all Map lists
    trans(TempMap, TransMap),				% Switching the rows and colums of the Map itself
    decodeAll_Loop(TransMap, Solutions).




/*
 * verify(euler(N, Length), Solution), given a euler Instance, verify that Solution is a counter example to euler
 * the predicate will set M and use an auxilary predicate to return True if that solution was verfied and false otherwise
 * if the auxilary predicate returned true, print to screen "verified:ok".
 */


/*
 * verifyAll(partition(N,Length), Solutions), given a partition Instance, will verify all the Solutions to the equation.
 * We will use verify_aux to verify each solution in Solutions.
*/

% Case for verify_aux returning false.
verifyAll(partition(N, Length), [Sol | _]):-
    not(verify_aux(N, Length, Sol, N)), !.

verifyAll(partition(N, Length), [_ | Solutions]):-
    verifyAll(partition(N, Length), Solutions).

% Verified.
verifyAll(_, []) :-
    writeln(verified:ok).
 

            
solveAll(Instance, Solutions) :-
    encode(Instance, Map, Cnf),
    satMulti(Cnf, 1000, _Count, _Time),
    decodeAll(Map,Solutions),
    verifyAll(Instance, Solutions), !.
