:- use_module(library(pce)).

% Types de crime
crime_type(assassinat).
crime_type(vol).
crime_type(escroquerie).

% Suspects
suspect(john).
suspect(mary).
suspect(alice).
suspect(bruno).
suspect(sophie).

% Faits - Regrouper par prédicat
has_motive(john, vol).
has_motive(mary, assassinat).
has_motive(alice, escroquerie).

was_near_crime_scene(john, vol).
was_near_crime_scene(mary, assassinat).

has_fingerprint_on_weapon(john, vol).
has_fingerprint_on_weapon(mary, assassinat).

has_bank_transaction(alice, escroquerie).
has_bank_transaction(bruno, escroquerie).

owns_fake_identity(sophie, escroquerie).


% Vol : doit avoir mobile + empreinte + être sur les lieux
is_guilty(Suspect, vol) :-
    has_motive(Suspect, vol),
    was_near_crime_scene(Suspect, vol),
    has_fingerprint_on_weapon(Suspect, vol).

% Assassinat : mobile + sur les lieux + (empreinte OU témoin)
is_guilty(Suspect, assassinat) :-
    has_motive(Suspect, assassinat),
    was_near_crime_scene(Suspect, assassinat),
    (   has_fingerprint_on_weapon(Suspect, assassinat)
    ;   eyewitness_identification(Suspect, assassinat)
    ).

% Escroquerie : au moins une preuve (transaction ou fausse identité)
is_guilty(Suspect, escroquerie) :-
    has_bank_transaction(Suspect, escroquerie).
is_guilty(Suspect, escroquerie) :-
    owns_fake_identity(Suspect, escroquerie).


start_interface :-
    new(D, dialog('Enquête policière en Prolog')),

    % Menu déroulant pour suspect
    send(D, append, new(SuspectItem, menu(suspect, cycle))),
    forall(suspect(S), send(SuspectItem, append, S)),

    % Menu déroulant pour type de crime
    send(D, append, new(CrimeItem, menu(crime, cycle))),
    forall(crime_type(C), send(CrimeItem, append, C)),

    % Zone d'affichage du résultat
    send(D, append, new(Result, label(result, 'Résultat: ...'))),

    % Bouton de vérification
    send(D, append,
         button(verifier,
                message(@prolog, verifier_culpabilite,
                        SuspectItem?selection,
                        CrimeItem?selection,
                        Result))),

    send(D, open).

% Vérification et affichage du résultat
verifier_culpabilite(Suspect, Crime, ResultLabel) :-
    (   is_guilty(Suspect, Crime)
    ->  send(ResultLabel, selection, string('%s est COUPABLE de %s', Suspect, Crime))
    ;   send(ResultLabel, selection, string('%s est NON coupable de %s', Suspect, Crime))
    ).
    