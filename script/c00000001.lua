-- Custom Pendulum Magician
local s,id=GetID()
function s.initial_effect(c)
    -- Pendulum Summon
    Pendulum.AddProcedure(c)

    -- Pendulum Effect: Special Summon this card when a Pendulum Monster is destroyed and place one of those monsters in the Pendulum Zone
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_DESTROYED)
    e1:SetRange(LOCATION_PZONE)
    e1:SetCountLimit(1)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCondition(s.pendcon)
    e1:SetTarget(s.pendtg)
    e1:SetOperation(s.pendop)
    c:RegisterEffect(e1)

    -- Monster Effect: Special Summon a monster from the Spell & Trap Zone, then place this card in the Pendulum Zone
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetTarget(s.montg)
    e2:SetOperation(s.monop)
    c:RegisterEffect(e2)
end

-- Pendulum Effect Condition: Check if Pendulum Monsters were destroyed
function s.pendcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(Card.IsType,1,nil,TYPE_PENDULUM)
end

-- Pendulum Effect Target: Target destroyed Pendulum Monsters
function s.pendtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    -- Select one destroyed Pendulum Monster to place in the Pendulum Zone
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
    local g=eg:FilterSelect(tp,Card.IsType,1,1,nil,TYPE_PENDULUM)
    Duel.SetTargetCard(g)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

-- Pendulum Effect Operation: Place chosen destroyed Pendulum Monster in the Pendulum Zone and Special Summon this card
function s.pendop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
        Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
    end
end

-- Monster Effect Target: Target a monster in the Spell & Trap Zone
function s.montg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_SZONE,0,1,nil,TYPE_MONSTER) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_SZONE)
end

-- Monster Effect Operation: Special Summon the selected monster and place this card in the Pendulum Zone
function s.monop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_SZONE,0,1,1,nil,TYPE_MONSTER)
    if #g>0 and Duel.SpecialSummon(g:GetFirst(),0,tp,tp,false,false,POS_FACEUP)~=0 then
        Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
    end
end
