%% DER Optimization
clear all; close all; clc ; started_at = datetime('now'); startsim = tic;

%% Optimization Parameters

%% Quick Constraints
nopv = 0;        % Turn off all PV
noees = 0;       % Turn off all EES/REES
tc = 1;          % On/Off transformer constraints
opt_t = 0;       % On/Off optimize transformer size (T_rated)
ic = 1;          % On/Off inverter constraints
nem_c = 1;       % On/Off NEM constraints 
dlpfc = 1;       % On/Off Decoupled Linearized Power Flow (DLPF) constraints 
lindist = 0;     % On/Off LinDistFlow constraints 
socc = 0;        % On/Off SOC constraints
voltage = 1;     % Use upped and lower limit for voltage 
VH = 1.05;       % Low Voltage Limit (p.u.)
VL = 0.95;       % High Voltage Limit(p.u.)
branchC = 1;     % On/Off Banch kVA constraints
primonly = 0;    % (1) Banch kVA constraints only on primary nodes. (0) Branch contraints on prim and secondary branches
Rmulti = 1;      % Multiplier for resistance in impedance matrix

if dlpfc || lindist 
    cnstrts = table(nopv,noees,tc,opt_t,ic,nem_c,dlpfc,lindist,voltage, VL,VH, branchC,primonly,Rmulti,'VariableNames',{'nopv','noees','tc','opt_t','ic','nem_c','dlpf','lindist','V','Vlow','Vhigh','Branch','primonly','Rmulti'})
else 
    cnstrts = table(nopv,noees,tc,opt_t,ic,nem_c,dlpfc,lindist,Rmulti,'VariableNames',{'nopv','noees','tc','opt_t','ic','nem_c','dlpf','lindist','Rmulti'})
end 

%% Load MATPOWER Test Case
%% For DERopt + Transformer Paper %54-node
%mpc = loadcase('caseAEC')
%mpc = loadcase('caseAEC_radial')

%T_map = [37 40	28	44	39	41	42	28	43	2	54	4	6	30	18	22	8	31	16	29	34	27	35	14	38	10	33	12	36	26	11];%Mar.18.19 %54-node %elec = base 

%[baseMVA, bus, gen, branch] = deal(mpc.baseMVA, mpc.bus, mpc.gen, mpc.branch);
% N = size(bus,1);  %number of nodes
% B = size(branch,1); %number of branches

%load Sb_rated;

%For radial case only 
% Sb_rated(10) = []; Sb_rated(21) = []; Sb_rated(33) = [];

%% For DERopt + DLPF Paper %84-node / 115-node + secondary 
% %mpc = loadcase('caseAEC_XFMR_2') %84 node
% %mpc = loadcase('caseAEC_XFMR_2_radial')
% mpc = loadcase('caseAEC_XFMR_4')
% 
% [baseMVA, bus, gen, branch] = deal(mpc.baseMVA, mpc.bus, mpc.gen, mpc.branch);
% N = size(bus,1);  %number of nodes
% B = size(branch,1); %number of branches
% 
% mpc.branch(:,3) = Rmulti.*mpc.branch(:,3);
% 
% %T_map = [65 76	84	82	78	74	72	84	70	4	12	7	15	10	39	44	19	47	34	67	59	53	61	30	80	22	57	27	63	51	24];%Apr.10.19 %84-node
% T_map = [106	111	115	114	112	110	109	101	108	85	88	86	89	87	96	97	90	98	95	107	103	100	104	94	113	91	102	93	105	99	92];%Jun.17.19 %115-node
% 
% load Sb_rated_86; Sb_rated = Sb_rated_86; %MVA %84-node / 115-node
% 
% Sb_extended = [0.04	0.04	0.04	0.04	0.04	0.04	0.08	0.08	0.08	0.08	0.04	0.04	0.04	0.04	0.04	0.04	0.08	0.08	0.08	0.08	0.08	0.08	0.08	0.08	0.08	0.08	0.08	0.08	0.08	0.08	0.08]'; %115-node
% Sb_rated = [Sb_rated ; Sb_extended]; % Add line drops Sb_rated  %115-node
% 
% %For radial case only
% %Sb_rated(16) = []; Sb_rated(32) = []; Sb_rated(37) = [];


%% IEEE-33 bus For MPC paper 
mpc = loadcase('case33')

[baseMVA, bus, gen, branch] = deal(mpc.baseMVA, mpc.bus, mpc.gen, mpc.branch);
N = size(bus,1);  %# of nodes
B = size(branch,1); %# of branches

%defined in opt_transformer_mpc.m
%T_map = [ 2 3 4 5 6 7 8 9 10 11 ]; 

Sb_rated = mpc.branch(:,6); %MVA 

%% TRANSFORMER (opt_transformer.m)
%tc = 1; % On/Off tranformer constraints 
alpha = 1;

%% Select Technologies
%nopv = 0; %Turn off all PV
%noees = 0; %Turn off all EES/REES

%% Too little PV/EES
toolittle_pv = 0;
toolittle_storage = 0;

%% PV (opt_pv.m)
pv_maxarea = 0;

%% NEM (opt_nem.m) 
%nem_c = 0; %On/Off NEM constraints 
%%% 1) NEM Credits to be less than Import Cost
net_import_on = 1;
%Select NEM to be calculated annually or monthly 
nem_annual = 1; nem_montly = 0;
%%% 2) Export >= net_import_limit.*import % 
net_import_limit = 1; % 1 = NET ZERO !!  

%% Island operation (opt_nem.m) 
island = 0;
load_shedding = 0.5; %Asusming 1-x% of the AEC load can be shed in case of a non-planned islanding. elec = load_shedding*elec

%% EES (opt_ees.m)
%%% Avoid simultaneous Charge and Discharge (xd & xc binaries)
ees_onoff = 0; 
%socc = 0; % SOC constraint: for each individual ees and rees, final SOC >= Initial SOC

%% REES (opt_var_cf.m)
%%%Allow renewable storage decision using EES type
rees_exist = 1;

%% Grid limits 
%%% On/Off Grid Import Limit 
grid_import_on = 0;
%%%Limit on grid import power  
import_limit = .8;

%% Building demand (blgd_loader.m)
bldgnum = 'AEC';

%%%Filter 8760 hourly data to a smaller set of days (1 = Yes)
filter_yr_2_day = 1;

%%% Moving average on building energy profile, with window being the filtering forward and backward range 
%%% (1 = on for always, 2 for eliminating zeros)
%%% Note: Good to use with raw unfiltered data, but will supress maximum/minmum loads
filtering = 0;
window = 3; % minimum percent
min_percent = 0.2; % if filtering = 2, the minimum load threshold as % of mean load

%% opt.m
%%%Choose optimizaiton solver 
opt_cplex = 0; %CPLEX, will do a model export YALMIP -> CPLEX
opt_yalmip = 1; %YALMIP, but calling CPLEX MILP solver

%% Loading data 
%% Building/solar data
%bldg_loader_rjf %Use 864-hour reduced dataset
%bldg_loader_rjf_2 %Only simulates worst-case RPF week
bldg_loader_mpc % MPC IEEE-33 bus

%% Tech Parameters/Costs
%%%Technology Parameters
tech_select
%%%Including Required Return with Capital Payment (1 = Yes)
req_return_on = 1;
%%%Technology Capital Costs
tech_payment

%% Utility Data
%%%Loading and formatting utility data
utility
%%%Energy charges for TOU Rates
elec_vecs

%% DERopt
%% Setting up variables and Objective function
fprintf('%s: Objective Function.', datestr(now,'HH:MM:SS'))
tic
opt_var_cf %%%Added NEM and wholesale export to the PV Section
elapsed = toc;
fprintf('Took %.2f seconds \n', elapsed)

%% General Equality Constraints
fprintf('%s: General Equalities.', datestr(now,'HH:MM:SS'))
tic
opt_gen_equalities
elapsed = toc;
fprintf('Took %.2f seconds \n', elapsed)

%% General Inequality Constraints
fprintf('%s: General Inequalities. ', datestr(now,'HH:MM:SS'))
tic
opt_gen_inequalities
elapsed = toc;
fprintf('Took %.2f seconds \n', elapsed)

%% Solar PV Constraints
fprintf('%s: PV Constraints.', datestr(now,'HH:MM:SS'))
tic
%opt_pv
opt_pv_2 
elapsed = toc;
fprintf('Took %.2f seconds \n', elapsed)

%% EES Constraints
fprintf('%s: EES Constraints.', datestr(now,'HH:MM:SS'))
tic
opt_ees
elapsed = toc;
fprintf('Took %.2f seconds \n', elapsed)

%% Inverter Constraints
fprintf('%s: Inverter Constraints.', datestr(now,'HH:MM:SS'))
ttime = tic;
%opt_inverter
opt_inverter_2
elapsed = toc(ttime);
fprintf('Took %.2f seconds \n', elapsed)
%% Transformer Constraints
fprintf('%s: Transformer Constraints.', datestr(now,'HH:MM:SS'))
ttime = tic;
%opt_transformer
opt_transformer_mpc
elapsed = toc(ttime);
fprintf('Took %.2f seconds \n', elapsed)

%% DLPF
if dlpfc ==1 
    fprintf('%s: DLPF.', datestr(now,'HH:MM:SS'))
    tic
    opt_DLPF
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)
end 
%% LinDistFlow 
if lindist ==1 
    fprintf('%s: LinDist.', datestr(now,'HH:MM:SS'))
    tic
    opt_LinDistFlow
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)
end 

%% Smart Inverter
fprintf('%s: Smart Inverter.', datestr(now,'HH:MM:SS'))
tic
%opt_smart_inverter
elapsed = toc;
fprintf('Took %.2f seconds \n', elapsed)

%% NEM Constraints
fprintf('%s: NEM Constraints.', datestr(now,'HH:MM:SS'))
tic
opt_nem
elapsed=toc;
fprintf('Took %.2f seconds \n', elapsed)

%% Optimize
fprintf('%s: Optimizing \n....', datestr(now,'HH:MM:SS'))
opt

%% Timer
finish = datetime('now') ; totalelapsed = toc(startsim)

%% Evaluating YALMIP sdpvars
yalmip_value

%% Post-processing and plots
ldn_post
%ldn_plots

check_constraints = min(check(Constraints));
[primal, dual ] = check(Constraints);

if check_constraints <= -1
    fprintf('Constraints violated:')
    check(Constraints(find(primal <= check_constraints)))
else 
    fprintf('YAS No Constraints violated!!!! ')
end

adopt
max(pv_curtail(:,10:19)) %check if residential is curtailing