const crypto = require('crypto');
const Prisma = require('prisma');
const {
    PrismaClient
} = require('@prisma/client');
const prisma = new PrismaClient({ /// TODO: remove prisma logging!
    log: [{
            emit: 'stdout',
            level: 'query',
        },
        {
            emit: 'stdout',
            level: 'error',
        },
        {
            emit: 'stdout',
            level: 'info',
        },
        {
            emit: 'stdout',
            level: 'warn',
        },
    ]
});

const subscribers = [];
const onRequestUpdates = (fn) => subscribers.push(fn);
const RequestsSubscriptionPayload = {
    subscribe: (parent, args, {
        pubsub
    }) => {
        const channel = Math.random().toString(36).slice(2, 15);
        onRequestUpdates(() => pubsub.publish(channel, {}));
        setTimeout(() => pubsub.publish(channel, {}), 0);
        return pubsub.asyncIterator(channel);
    }
};

const resolver = {

    getUserMemory: async (args, context) => {
        let answer;
        if (args.TableID)
            answer = await prisma.UserMemory.findMany({
                where: {
                    AND: [{
                        UID: args.UID
                    }, {
                        TableID: args.TableID
                    }, {
                        TableName: args.TableName
                    }]
                }
            });
        else
            answer = await prisma.UserMemory.findMany({
                where: {
                    UID: args.UID
                }
            });
        console.log(answer);
        return answer;
    },

    getRequests: async (args, context) => {
        let answer;
        if (args.State) {
            answer = await prisma.Requests.findMany({
                take: 75,
                where: {
                    State: args.State
                },
                include: {
                    resolvers: true
                }
            });
        } else {
            answer = await prisma.Requests.findMany({
                take: 75,
                include: {
                    resolver: true
                }
            });
        }
        console.log(answer);
        return answer;
    },

    getSource: async (args, context) => {
        let answer;
        switch (context.type) {
            case 'name':
                answer = await prisma.Source.findMany({
                    where: {
                        Name: args.Name
                    }
                });
                break;
            case 'id':
                answer = await prisma.Source.findMany({
                    where: {
                        SID: args.SID
                    }
                });
                break;
            default:
                answer = await prisma.Source.findMany();
                break;
        }
        console.log(answer);
        return answer;
    },

    getImages: async (args, context) => {
        let answer;
        switch (context.type) {
            case 'id':
                answer = await prisma.Images.findMany({
                    where: {
                        IID: args.IID
                    }
                });
                break;
            default:
                answer = await prisma.Images.findMany();
                break;
        }
        console.log(answer);
        return answer;
    },

    getBasicAbilities: async (args, context) => {
        let answer;
        switch (context.type) {
            case 'name':
                answer = await prisma.BasicAbilities.findMany({
                    where: {
                        Name: args.Name
                    }
                });
                break;
            case 'id':
                answer = await prisma.BasicAbilities.findMany({
                    where: {
                        BAID: args.BAID
                    }
                });
                break;
            default:
                answer = await prisma.BasicAbilities.findMany();
                break;
        }
        console.log(answer);
        return answer;
    },

    getMonsters: async (args, context) => {
        let answer;
        switch (context.type) {
            case 'name':
                answer = await prisma.Monsters.findMany({
                    where: {
                        Name: args.Name
                    }
                });
                break;
            case 'id':
                answer = await prisma.Monsters.findMany({
                    where: {
                        MID: args.MID
                    }
                });
                break;
            case 'cr':
                answer = await prisma.Monsters.findMany({
                    where: {
                        CR: args.CR
                    }
                });
                break;
            case 'alignment':
                answer = await prisma.Monsters.findMany({
                    where: {
                        Alignment: args.Alignment
                    }
                });
            default:
                answer = await prisma.Monsters.findMany();
                break;
        }
        console.log(answer);
        return answer;
    },

    getMonsterTypes: async (args, context) => {
        let answer;
        switch (context.type) {
            case 'name':
                answer = await prisma.MonsterTypes.findMany({
                    where: {
                        Name: args.Name
                    }
                });
                break;
            case 'id':
                answer = await prisma.MonsterTypes.findMany({
                    where: {
                        TID: args.TID
                    }
                });
                break;
            default:
                answer = await prisma.MonsterTypes.findMany();
                break;
        }
        console.log(answer);
        return answer;
    },

    getFeatTypes: async (args, context) => {
        let answer;
        switch (context.type) {
            case 'name':
                answer = await prisma.FeatTypes.findMany({
                    where: {
                        Name: args.Name
                    }
                });
                break;
            case 'id':
                answer = await prisma.FeatTypes.findMany({
                    where: {
                        FTID: args.FTID
                    }
                });
                break;
            default:
                answer = await prisma.FeatTypes.findMany();
                break;
        }
        console.log(answer);
        return answer;
    },

    getFeats: async (args, context) => {
        let answer;
        switch (context.type) {
            case 'name':
                answer = await prisma.Feats.findMany({
                    where: {
                        Name: args.Name
                    }
                });
                break;
            case 'id':
                answer = await prisma.Feats.findMany({
                    where: {
                        FID: args.FID
                    }
                });
                break;
            default:
                answer = await prisma.Feats.findMany();
                break;
        }
        console.log(answer);
        return answer;
    },

    getAlignments: async (args, context) => {
        let answer;
        switch (context.type) {
            case 'name':
                answer = await prisma.Alignments.findMany({
                    where: {
                        Name: args.Name
                    }
                });
                break;
            case 'id':
                answer = await prisma.Alignments.findMany({
                    where: {
                        AID: args.AID
                    }
                });
                break;
            default:
                answer = await prisma.Alignments.findMany();
                break;
        }
        console.log(answer);
        return answer;
    },

    getClassFeatures: async (args, context) => {
        let answer;
        switch (context.type) {
            case 'name':
                answer = await prisma.ClassFeatures.findMany({
                    where: {
                        Name: args.Name
                    }
                });
                break;
            case 'id':
                answer = await prisma.ClassFeatures.findMany({
                    where: {
                        CFID: args.SID
                    }
                });
                break;
            case 'class':
                answer = await prisma.ClassFeatures.findMany({
                    where: {
                        Class: args.Class
                    }
                });
                break;
            default:
                answer = await prisma.ClassFeatures.findMany();
                break;
        }
        console.log(answer);
        return answer;
    },

    getSkills: async (args, context) => {
        let answer;
        switch (context.type) {
            case 'name':
                answer = await prisma.Skills.findMany({
                    where: {
                        Name: args.Name
                    }
                });
                break;
            case 'id':
                answer = await prisma.Skills.findMany({
                    where: {
                        SID: args.SID
                    }
                });
                break;
            default:
                answer = await prisma.Skills.findMany();
                break;
        }
        console.log(answer);
        return answer;
    },

    getClasses: async (args, context) => {
        let answer;
        switch (context.type) {
            case 'name':
                answer = await prisma.Classes.findMany({
                    where: {
                        Name: args.Name
                    }
                });
                break;
            case 'id':
                answer = await prisma.Classes.findMany({
                    where: {
                        CID: args.CID
                    }
                });
                break;
            default:
                answer = await prisma.Classes.findMany();
                break;
        }
        console.log(answer);
        return answer;
    },

    getRaces: async (args, context) => {
        let answer;
        switch (context.type) {
            case 'name':
                answer = await prisma.Races.findMany({
                    where: {
                        Name: args.Name
                    }
                });
                break;
            case 'id':
                answer = await prisma.Races.findMany({
                    where: {
                        RID: args.RID
                    }
                });
                break;
            default:
                answer = await prisma.Races.findMany();
                break;
        }
        console.log(answer);
        return answer;
    },

    getEquipmentTypes: async (args, context) => {
        let answer;
        switch (context.type) {
            case 'name':
                answer = await prisma.EquipmentTypes.findMany({
                    where: {
                        Name: args.Name
                    }
                });
                break;
            case 'id':
                answer = await prisma.EquipmentTypes.findMany({
                    where: {
                        ETID: args.ETID
                    }
                });
                break;
            default:
                answer = await prisma.EquipmentTypes.findMany();
                break;
        }
        console.log(answer);
        return answer;
    },

    getEquipment: async (args, context) => {
        let answer;
        switch (context.type) {
            case 'name':
                answer = await prisma.Equipment.findMany({
                    where: {
                        Name: args.Name
                    }
                });
                break;
            case 'id':
                answer = await prisma.Equipment.findMany({
                    where: {
                        EID: args.EID
                    }
                });
                break;
            default:
                answer = await prisma.Equipment.findMany();
                break;
        }
        console.log(answer);
        return answer;
    },

    getSpellTypes: async (args, context) => {
        let answer;
        switch (context.type) {
            case 'name':
                answer = await prisma.SpellTypes.findMany({
                    where: {
                        Name: args.Name
                    }
                });
                break;
            case 'id':
                answer = await prisma.SpellTypes.findMany({
                    where: {
                        STID: args.STID
                    }
                });
                break;
            default:
                answer = await prisma.SpellTypes.findMany();
                break;
        }
        console.log(answer);
        return answer;
    },

    getMagicSubschools: async (args, context) => {
        let answer;
        switch (context.type) {
            case 'name':
                answer = await prisma.MagicSubschools.findMany({
                    where: {
                        Name: args.Name
                    }
                });
                break;
            case 'id':
                answer = await prisma.MagicSubschools.findMany({
                    where: {
                        MSID: args.MSID
                    }
                });
                break;
            case 'school':
                answer = await prisma.MagicSubschools.findMany({
                    where: {
                        School: args.School
                    }
                });
                break;
            default:
                answer = await prisma.MagicSubschools.findMany();
                break;
        }
        console.log(answer);
        return answer;
    },

    getMagicSchools: async (args, context) => {
        let answer;
        switch (context.type) {
            case 'name':
                answer = await prisma.MagicSchools.findMany({
                    where: {
                        Name: args.Name
                    }
                });
                break;
            case 'id':
                answer = await prisma.MagicSchools.findMany({
                    where: {
                        MSID: args.MSID
                    }
                });
                break;
            default:
                answer = await prisma.MagicSchools.findMany();
                break;
        }
        console.log(answer);
        return answer;
    },

    getSpellComponents: async (args, context) => {
        let answer;
        switch (context.type) {
            case 'name':
                answer = await prisma.SpellComponents.findMany({
                    where: {
                        Name: args.Name
                    }
                });
                break;
            case 'id':
                answer = await prisma.SpellComponents.findMany({
                    where: {
                        SCID: args.SCID
                    }
                });
                break;
            default:
                answer = await prisma.SpellComponents.findMany();
                break;
        }
        console.log(answer);
        return answer;
    },

    getSpells: async (args, context) => {
        let answer;
        switch (context.type) {
            case 'name':
                answer = await prisma.Spells.findMany({
                    where: {
                        Name: args.Name
                    }
                });
                break;
            case 'id':
                answer = await prisma.Spells.findMany({
                    where: {
                        SID: args.SID
                    }
                });
                break;
            default:
                answer = await prisma.Spells.findMany();
                break;
        }
        console.log(answer);
        return answer;
    },

    getRules: async (args, context) => {
        let answer;
        switch (context.type) {
            case 'name':
                answer = await prisma.Rules.findMany({
                    where: {
                        Name: args.Name
                    }
                });
                break;
            case 'id':
                answer = await prisma.Rules.findMany({
                    where: {
                        RID: args.RID
                    }
                });
                break;
            default:
                answer = await prisma.Rules.findMany();
                break;
        }
        console.log(answer);
        return answer;
    },

    getMagicEffects: async (args, context) => {
        let answer;
        switch (context.type) {
            case 'name':
                answer = await prisma.MagicEffects.findMany({
                    where: {
                        Name: args.Name
                    }
                });
                break;
            case 'id':
                answer = await prisma.MagicEffects.findMany({
                    where: {
                        MEID: args.MEID
                    }
                });
                break;
            default:
                answer = await prisma.MagicEffects.findMany();
                break;
        }
        console.log(answer);
        return answer;
    },

    getMagicItems: async (args, context) => {
        let answer;
        switch (context.type) {
            case 'name':
                answer = await prisma.MagicItems.findMany({
                    where: {
                        Name: args.Name
                    }
                });
                break;
            case 'id':
                answer = await prisma.MagicItems.findMany({
                    where: {
                        MIID: args.MIID
                    }
                });
                break;
            default:
                answer = await prisma.MagicItems.findMany();
                break;
        }
        console.log(answer);
        return answer;
    },

    getDungeonTypes: async (args, context) => {
        let answer;
        switch (context.type) {
            case 'name':
                answer = await prisma.DungeonTypes.findMany({
                    where: {
                        Name: args.Name
                    }
                });
                break;
            case 'id':
                answer = await prisma.DungeonTypes.findMany({
                    where: {
                        DTID: args.DTID
                    }
                });
                break;
            default:
                answer = await prisma.DungeonTypes.findMany();
                break;
        }
        console.log(answer);
        return answer;
    },

    getDungeonElements: async (args, context) => {
        let answer;
        switch (context.type) {
            case 'name':
                answer = await prisma.DungeonElements.findMany({
                    where: {
                        Name: args.Name
                    }
                });
                break;
            case 'id':
                answer = await prisma.DungeonElements.findMany({
                    where: {
                        DEID: args.DEID
                    }
                });
                break;
            default:
                answer = await prisma.DungeonElements.findMany();
                break;
        }
        console.log(answer);
        return answer;
    },

    getDungeonSubelements: async (args, context) => {
        let answer;
        switch (context.type) {
            case 'name':
                answer = await prisma.DungeonSubelements.findMany({
                    where: {
                        Name: args.Name
                    }
                });
                break;
            case 'id':
                answer = await prisma.DungeonSubelements.findMany({
                    where: {
                        DSID: args.DSID
                    }
                });
                break;
            default:
                answer = await prisma.DungeonSubelements.findMany();
                break;
        }
        console.log(answer);
        return answer;
    },

    getSiegeEngines: async (args, context) => {
        let answer;
        switch (context.type) {
            case 'name':
                answer = await prisma.SiegeEngines.findMany({
                    where: {
                        Name: args.Name
                    }
                });
                break;
            case 'id':
                answer = await prisma.SiegeEngines.findMany({
                    where: {
                        SEID: args.SEID
                    }
                });
                break;
            default:
                answer = await prisma.SiegeEngines.findMany();
                break;
        }
        console.log(answer);
        return answer;
    },

    getHazards: async (args, context) => {
        let answer;
        switch (context.type) {
            case 'name':
                answer = await prisma.Hazards.findMany({
                    take: 25,
                    where: {
                        OR: [{
                                Name: {
                                    contains: decodeURIComponent(args.Name)
                                }
                            },
                            {
                                Name: {
                                    contains: decodeURIComponent(args.Name).toUpperCase()
                                }
                            }, {
                                Name: {
                                    contains: decodeURIComponent(args.Name).toLowerCase()
                                }
                            }
                        ]
                    }
                });
                break;
            case 'id':
                answer = await prisma.Hazards.findMany({
                    where: {
                        HID: args.HID
                    },
                    include: {
                        source: true
                    }
                });
                break;
            default:
                answer = await prisma.Hazards.findMany();
                break;
        }
        console.log(answer);
        return answer;
    },

    getWilderness: async (args, context) => {
        let answer;
        switch (context.type) {
            case 'name':
                answer = await prisma.Wilderness.findMany({
                    take: 25,
                    where: {
                        OR: [{
                                Name: {
                                    contains: decodeURIComponent(args.Name)
                                }
                            },
                            {
                                Name: {
                                    contains: decodeURIComponent(args.Name).toUpperCase()
                                }
                            }, {
                                Name: {
                                    contains: decodeURIComponent(args.Name).toLowerCase()
                                }
                            }, {
                                wilddetail: {
                                    some: {
                                        Name: {
                                            contains: decodeURIComponent(args.Name)
                                        }
                                    }
                                }
                            }, {
                                wilddetail: {
                                    some: {
                                        Name: {
                                            contains: decodeURIComponent(args.Name).toLowerCase()
                                        }
                                    }
                                }
                            }, {
                                wilddetail: {
                                    some: {
                                        Name: {
                                            contains: decodeURIComponent(args.Name).toUpperCase()
                                        }
                                    }
                                }
                            }
                        ]
                    }
                });
                break;
            case 'id':
                answer = await prisma.Wilderness.findMany({
                    where: {
                        WID: args.WID
                    },
                    include: {
                        source: true,
                        wilddetail: true
                    }
                });
                break;
            default:
                answer = await prisma.Wilderness.findMany();
                break;
        }
        console.log(answer);
        return answer;
    },

    getWildDetails: async (args, context) => {
        let answer;
        switch (context.type) {
            case 'name':
                answer = await prisma.WildDetails.findMany({
                    where: {
                        Name: args.Name
                    }
                });
                break;
            case 'id':
                answer = await prisma.WildDetails.findMany({
                    where: {
                        WDID: args.WDID
                    }
                });
                break;
            default:
                answer = await prisma.WildDetails.findMany();
                break;
        }
        console.log(answer);
        return answer;
    },

    getTrapTypes: async (args, context) => {
        let answer;
        switch (context.type) {
            case 'name':
                answer = await prisma.TrapTypes.findMany({
                    where: {
                        Name: args.Name
                    }
                });
                break;
            case 'id':
                answer = await prisma.TrapTypes.findMany({
                    where: {
                        TTID: args.TTID
                    }
                });
                break;
            default:
                answer = await prisma.TrapTypes.findMany();
                break;
        }
        console.log(answer);
        return answer;
    },

    getTrapResets: async (args, context) => {
        let answer;
        switch (context.type) {
            case 'name':
                answer = await prisma.TrapResets.findMany({
                    where: {
                        Name: args.Name
                    }
                });
                break;
            case 'id':
                answer = await prisma.TrapResets.findMany({
                    where: {
                        TRID: args.TRID
                    }
                });
                break;
            default:
                answer = await prisma.TrapResets.findMany();
                break;
        }
        console.log(answer);
        return answer;
    },

    getTrapTriggers: async (args, context) => {
        let answer;
        switch (context.type) {
            case 'name':
                answer = await prisma.TrapTriggers.findMany({
                    where: {
                        Name: args.Name
                    }
                });
                break;
            case 'id':
                answer = await prisma.TrapTriggers.findMany({
                    where: {
                        TTID: args.TTID
                    }
                });
                break;
            default:
                answer = await prisma.TrapTriggers.findMany();
                break;
        }
        console.log(answer);
        return answer;
    },

    getTraps: async (args, context) => {
        let answer;
        switch (context.type) {
            case 'name':
                answer = await prisma.Traps.findMany({
                    where: {
                        Name: args.Name
                    }
                });
                break;
            case 'id':
                answer = await prisma.Traps.findMany({
                    where: {
                        TID: args.TID
                    }
                });
                break;
            default:
                answer = await prisma.Traps.findMany();
                break;
        }
        console.log(answer);
        return answer;
    },

    getWeather: async (args, context) => {
        let answer;
        switch (context.type) {
            case 'name':
                answer = await prisma.Weather.findMany({
                    take: 25,
                    where: {
                        OR: [{
                                Name: {
                                    contains: decodeURIComponent(args.Name)
                                }
                            },
                            {
                                Name: {
                                    contains: decodeURIComponent(args.Name).toUpperCase()
                                }
                            }, {
                                Name: {
                                    contains: decodeURIComponent(args.Name).toLowerCase()
                                }
                            }, {
                                subweather: {
                                    some: {
                                        Name: {
                                            contains: decodeURIComponent(args.Name)
                                        }
                                    }
                                }
                            }, {
                                subweather: {
                                    some: {
                                        Name: {
                                            contains: decodeURIComponent(args.Name).toLowerCase()
                                        }
                                    }
                                }
                            }, {
                                subweather: {
                                    some: {
                                        Name: {
                                            contains: decodeURIComponent(args.Name).toUpperCase()
                                        }
                                    }
                                }
                            }
                        ]
                    }
                });
                break;
            case 'id':
                answer = await prisma.Weather.findMany({
                    where: {
                        WID: args.WID
                    },
                    include: {
                        source: true,
                        subweather: true,
                    }
                });
                break;
            default:
                answer = await prisma.Weather.findMany();
                break;
        }
        console.log(answer);
        return answer;
    },

    getSubweather: async (args, context) => {
        let answer;
        switch (context.type) {
            case 'name':
                answer = await prisma.Subweather.findMany({
                    where: {
                        Name: args.Name
                    }
                });
                break;
            case 'id':
                answer = await prisma.Subweather.findMany({
                    where: {
                        SWID: args.SWID
                    }
                });
                break;
            default:
                answer = await prisma.Subweather.findMany();
                break;
        }
        console.log(answer);
        return answer;
    },

    getGods: async (args, context) => {
        let answer;
        switch (context.type) {
            case 'name':
                answer = await prisma.Gods.findMany({
                    where: {
                        Name: args.Name
                    }
                });
                break;
            case 'id':
                answer = await prisma.Gods.findMany({
                    where: {
                        GID: args.GID
                    }
                });
                break;
            default:
                answer = await prisma.Gods.findMany();
                break;
        }
        console.log(answer);
        return answer;
    },

    getUsers: async (args, context) => {
        let answer;
        console.log(args.Name, args.Password);
        //let hashpass = crypto.createHash('md5').update(args.password).digest('hex');
        switch (context.type) {
            default:
                answer = await prisma.Users.findMany({
                    where: {
                        Name: decodeURIComponent(args.Name),
                        Password: decodeURIComponent(args.Password) //hashpass
                    }
                });
                break;
        }
        console.log(answer);
        return answer;
    },

    getGameCampains: async (args, context) => {
        let answer;
        switch (context.type) {
            case 'user':
                answer = await prisma.GameCampains.findMany({
                    take: 25,
                    where: {
                        Master: args.Master
                    },
                    include: {
                        gamesessions: true
                    }
                });
                break;
            case 'id':
                answer = await prisma.GameCampains.findMany({
                    where: {
                        GCID: args.GCID
                    },
                    include: {
                        gamesessions: true,
                    }
                });
                break;
            default:
                answer = await prisma.GameCampains.findMany();
                break;
        }
        console.log(answer);
        return answer;
    },

    getGameSessions: async (args, context) => {
        let answer;
        switch (context.type) {
            case 'name':
                answer = await prisma.GameSessions.findMany({
                    where: {
                        Name: args.Name
                    }
                });
                break;
            case 'id':
                answer = await prisma.GameSessions.findMany({
                    where: {
                        GSID: args.GSID
                    }
                });
                break;
            default:
                answer = await prisma.GameSessions.findMany();
                break;
        }
        console.log(answer);
        return answer;
    },

    getPlayers: async (args, context) => {
        let answer;
        switch (context.type) {
            case 'name':
                answer = await prisma.Players.findMany({
                    where: {
                        Name: args.Name
                    }
                });
                break;
            case 'id':
                answer = await prisma.Players.findMany({
                    where: {
                        PID: args.PID
                    }
                });
                break;
            default:
                answer = await prisma.Players.findMany();
                break;
        }
        console.log(answer);
        return answer;
    },

    getCharacters: async (args, context) => {
        let answer;
        switch (context.type) {
            case 'name':
                answer = await prisma.Characters.findMany({
                    where: {
                        Name: args.Name
                    }
                });
                break;
            case 'id':
                answer = await prisma.Characters.findMany({
                    where: {
                        CID: args.CID
                    }
                });
                break;
            default:
                answer = await prisma.Characters.findMany();
                break;
        }
        console.log(answer);
        return answer;
    },

    setUserMemory: async (args, context) => {
        let answer;
        if (args.UMID)
            answer = await prisma.UserMemory.update({
                data: {
                    UID: args.UID,
                    TableName: decodeURIComponent(args.TableName),
                    TableID: args.TableID,
                    Name: decodeURIComponent(args.Name)
                },
                where: {
                    UMID: args.UMID
                }
            });
        else
            answer = await prisma.UserMemory.create({
                data: {
                    UID: args.UID,
                    TableName: decodeURIComponent(args.TableName),
                    TableID: args.TableID,
                    Name: decodeURIComponent(args.Name)
                }
            });
        console.log(answer);
        return answer;
    },

    setRequest: async (args, context) => {
        let answer;
        if (args.Sender)
            answer = await prisma.Requests.create({
                data: {
                    Message: decodeURIComponent(args.Message),
                    State: args.State,
                    Sender: args.Sender
                }
            });
        else if (args.resolver) {
            answer = await prisma.Requests.update({
                data: {
                    resolver: {
                        connect: {
                            UID: args.resolver.UID
                        }
                    },
                    State: args.State
                },
                where: {
                    RID: args.RID
                },
                include: {
                    resolver: true
                }
            });
        } else
            answer = await prisma.Requests.create({
                data: {
                    Message: decodeURIComponent(args.Message),
                    State: args.State
                }
            });
        subscribers.forEach((fn) => fn());
        console.log(answer);
        return answer;
    },

    setSource: async (args, context) => {
        let upsertParams = null;
        let answer = null;
        if (args.SID) {
            upsertParams = {
                data: args
            };
            upsertParams.where = {
                SID: args.SID
            };
            answer = await prisma.Source.update(upsertParams);
        } else {
            upsertParams = {
                data: args
            };
            answer = await prisma.Source.create(upsertParams);
        }
        console.log(answer);
        return answer;
    },

    setImage: async (args, context) => {
        let upsertParams = null;
        let answer = null;
        if (args.IID) {
            upsertParams = {
                data: args
            };
            upsertParams.where = {
                IID: args.IID
            };
            answer = await prisma.Images.update(upsertParams);
        } else {
            upsertParams = {
                data: args
            };
            answer = await prisma.Images.create(upsertParams);
        }
        console.log(answer);
        return answer;
    },

    setBAbility: async (args, context) => {
        let upsertParams = null;
        let answer = null;
        if (args.BAID) {
            upsertParams = {
                data: args
            };
            upsertParams.where = {
                BAID: args.BAID
            };
            answer = await prisma.BasicAbilities.update(upsertParams);
        } else {
            upsertParams = {
                data: args
            };
            answer = await prisma.BasicAbilities.create(upsertParams);
        }
        console.log(answer);
        return answer;
    },

    setMonster: async (args, context) => {
        let upsertParams = null;
        let answer = null;
        if (args.MID) {
            upsertParams = {
                data: args
            };
            upsertParams.where = {
                MID: args.MID
            };
            answer = await prisma.Monsters.update(upsertParams);
        } else {
            upsertParams = {
                data: args
            };
            answer = await prisma.Monsters.create(upsertParams);
        }
        console.log(answer);
        return answer;
    },

    setMonsterType: async (args, context) => {
        let upsertParams = null;
        let answer = null;
        if (args.TID) {
            upsertParams = {
                data: args
            };
            upsertParams.where = {
                TID: args.TID
            };
            answer = await prisma.MonsterTypes.update(upsertParams);
        } else {
            upsertParams = {
                data: args
            };
            answer = await prisma.MonsterTypes.create(upsertParams);
        }
        console.log(answer);
        return answer;
    },

    setFeatType: async (args, context) => {
        let upsertParams = null;
        let answer = null;
        if (args.FTID) {
            upsertParams = {
                data: args
            };
            upsertParams.where = {
                FTID: args.FTID
            };
            answer = await prisma.FeatTypes.update(upsertParams);
        } else {
            upsertParams = {
                data: args
            };
            answer = await prisma.FeatTypes.create(upsertParams);
        }
        console.log(answer);
        return answer;
    },

    setFeat: async (args, context) => {
        let upsertParams = null;
        let answer = null;
        if (args.FID) {
            upsertParams = {
                data: args
            };
            upsertParams.where = {
                FID: args.FID
            };
            answer = await prisma.Feats.update(upsertParams);
        } else {
            upsertParams = {
                data: args
            };
            answer = await prisma.Feats.create(upsertParams);
        }
        console.log(answer);
        return answer;
    },

    setAlignment: async (args, context) => {
        let upsertParams = null;
        let answer = null;
        if (args.AID) {
            upsertParams = {
                data: args
            };
            upsertParams.where = {
                AID: args.AID
            };
            answer = await prisma.Alignments.update(upsertParams);
        } else {
            upsertParams = {
                data: args
            };
            answer = await prisma.Alignments.create(upsertParams);
        }
        console.log(answer);
        return answer;
    },

    setSkill: async (args, context) => {
        let upsertParams = null;
        let answer = null;
        if (args.SID) {
            upsertParams = {
                data: args
            };
            upsertParams.where = {
                SID: args.SID
            };
            answer = await prisma.Skills.update(upsertParams);
        } else {
            upsertParams = {
                data: args
            };
            answer = await prisma.Skills.create(upsertParams);
        }
        console.log(answer);
        return answer;
    },

    setClass: async (args, context) => {
        let upsertParams = null;
        let answer = null;
        if (args.CID) {
            upsertParams = {
                data: args
            };
            upsertParams.where = {
                CID: args.CID
            };
            answer = await prisma.Classes.update(upsertParams);
        } else {
            upsertParams = {
                data: args
            };
            answer = await prisma.Classes.create(upsertParams);
        }
        console.log(answer);
        return answer;
    },

    setRace: async (args, context) => {
        let upsertParams = null;
        let answer = null;
        if (args.RID) {
            upsertParams = {
                data: args
            };
            upsertParams.where = {
                RID: args.RID
            };
            answer = await prisma.Races.update(upsertParams);
        } else {
            upsertParams = {
                data: args
            };
            answer = await prisma.Races.create(upsertParams);
        }
        console.log(answer);
        return answer;
    },

    setEquipmentType: async (args, context) => {
        let upsertParams = null;
        let answer = null;
        if (args.ETID) {
            upsertParams = {
                data: args
            };
            upsertParams.where = {
                ETID: args.ETID
            };
            answer = await prisma.EquipmentTypes.update(upsertParams);
        } else {
            upsertParams = {
                data: args
            };
            answer = await prisma.EquipmentTypes.create(upsertParams);
        }
        console.log(answer);
        return answer;
    },

    setEquipment: async (args, context) => {
        let upsertParams = null;
        let answer = null;
        if (args.EID) {
            upsertParams = {
                data: args
            };
            upsertParams.where = {
                EID: args.EID
            };
            answer = await prisma.Equipment.update(upsertParams);
        } else {
            upsertParams = {
                data: args
            };
            answer = await prisma.Equipment.create(upsertParams);
        }
        console.log(answer);
        return answer;
    },

    setSpellType: async (args, context) => {
        let upsertParams = null;
        let answer = null;
        if (args.STID) {
            upsertParams = {
                data: args
            };
            upsertParams.where = {
                STID: args.STID
            };
            answer = await prisma.SpellTypes.update(upsertParams);
        } else {
            upsertParams = {
                data: args
            };
            answer = await prisma.SpellTypes.create(upsertParams);
        }
        console.log(answer);
        return answer;
    },

    setMagicSubschool: async (args, context) => {
        let upsertParams = null;
        let answer = null;
        if (args.MSID) {
            upsertParams = {
                data: args
            };
            upsertParams.where = {
                MSID: args.MSID
            };
            answer = await prisma.MagicSubschools.update(upsertParams);
        } else {
            upsertParams = {
                data: args
            };
            answer = await prisma.MagicSubschools.create(upsertParams);
        }
        console.log(answer);
        return answer;
    },

    setMagicSchool: async (args, context) => {
        let upsertParams = null;
        let answer = null;
        if (args.MSID) {
            upsertParams = {
                data: args
            };
            upsertParams.where = {
                MSID: args.MSID
            };
            answer = await prisma.MagicSchools.update(upsertParams);
        } else {
            upsertParams = {
                data: args
            };
            answer = await prisma.MagicSchools.create(upsertParams);
        }
        console.log(answer);
        return answer;
    },

    setSpell: async (args, context) => {
        let upsertParams = null;
        let answer = null;
        if (args.SID) {
            upsertParams = {
                data: args
            };
            upsertParams.where = {
                SID: args.SID
            };
            answer = await prisma.Spells.update(upsertParams);
        } else {
            upsertParams = {
                data: args
            };
            answer = await prisma.Spells.create(upsertParams);
        }
        console.log(answer);
        return answer;
    },

    setRule: async (args, context) => {
        let upsertParams = null;
        let answer = null;
        if (args.RID) {
            upsertParams = {
                data: args
            };
            upsertParams.where = {
                RID: args.RID
            };
            answer = await prisma.Rules.update(upsertParams);
        } else {
            upsertParams = {
                data: args
            };
            answer = await prisma.Rules.create(upsertParams);
        }
        console.log(answer);
        return answer;
    },

    setMagicItem: async (args, context) => {
        let upsertParams = null;
        let answer = null;
        if (args.MIID) {
            upsertParams = {
                data: args
            };
            upsertParams.where = {
                MIID: args.MIID
            };
            answer = await prisma.MagicItems.update(upsertParams);
        } else {
            upsertParams = {
                data: args
            };
            answer = await prisma.MagicItems.create(upsertParams);
        }
        console.log(answer);
        return answer;
    },

    setDungeonType: async (args, context) => {
        let upsertParams = null;
        let answer = null;
        if (args.DTID) {
            upsertParams = {
                data: args
            };
            upsertParams.where = {
                DTID: args.DTID
            };
            answer = await prisma.DungeonTypes.update(upsertParams);
        } else {
            upsertParams = {
                data: args
            };
            answer = await prisma.DungeonTypes.create(upsertParams);
        }
        console.log(answer);
        return answer;
    },

    setDungeonElement: async (args, context) => {
        let upsertParams = null;
        let answer = null;
        if (args.DEID) {
            upsertParams = {
                data: args
            };
            upsertParams.where = {
                DEID: args.DEID
            };
            answer = await prisma.DungeonElements.update(upsertParams);
        } else {
            upsertParams = {
                data: args
            };
            answer = await prisma.DungeonElements.create(upsertParams);
        }
        console.log(answer);
        return answer;
    },

    setDungeonSubelement: async (args, context) => {
        let upsertParams = null;
        let answer = null;
        if (args.DSID) {
            upsertParams = {
                data: args
            };
            upsertParams.where = {
                DSID: args.DSID
            };
            answer = await prisma.DungeonSubelements.update(upsertParams);
        } else {
            upsertParams = {
                data: args
            };
            answer = await prisma.DungeonSubelements.create(upsertParams);
        }
        console.log(answer);
        return answer;
    },

    setSiegeEngine: async (args, context) => {
        let upsertParams = null;
        let answer = null;
        if (args.SEID) {
            upsertParams = {
                data: args
            };
            upsertParams.where = {
                SEID: args.SEID
            };
            answer = await prisma.SiegeEngines.update(upsertParams);
        } else {
            upsertParams = {
                data: args
            };
            answer = await prisma.SiegeEngines.create(upsertParams);
        }
        console.log(answer);
        return answer;
    },

    setHazard: async (args, context) => {
        let upsertParams = null;
        let answer = null;
        if (args.HID) {
            upsertParams = {
                data: {
                    Name: decodeURIComponent(args.Name),
                    Description: decodeURIComponent(args.Description),
                    source: {
                        connectOrCreate: {
                            where: {
                                Name: args.source.Name
                            },
                            create: {
                                Name: args.source.Name
                            }
                        }
                    },
                    userupd: {
                        connect: {
                            Name: args.useradd.Name
                        }
                    }
                },
                include: {
                    sources: true,
                }
            };
            upsertParams.where = {
                HID: args.HID
            };
            answer = await prisma.Hazards.update(upsertParams);
        } else {
            upsertParams = {
                data: {
                    Name: decodeURIComponent(args.Name),
                    Description: decodeURIComponent(args.Description),
                    source: {
                        connectOrCreate: {
                            where: {
                                Name: args.source.Name
                            },
                            create: {
                                Name: args.source.Name
                            }
                        }
                    },
                    useradd: {
                        connect: {
                            Name: args.useradd.Name
                        }
                    }
                },
                include: {
                    source: true,
                    useradd: true,
                }
            };
            answer = await prisma.Hazards.create(upsertParams);
        }
        console.log(answer);
        return answer;
    },

    setWilderness: async (args, context) => {
        let upsertParams = null;
        let answer = null;
        if (args.WID) {
            upsertParams = {
                data: {
                    Name: decodeURIComponent(args.Name),
                    Description: decodeURIComponent(args.Description),
                    source: {
                        connectOrCreate: {
                            where: {
                                Name: decodeURIComponent(args.source.Name)
                            },
                            create: {
                                Name: decodeURIComponent(args.source.Name)
                            }
                        },
                    },
                    userupd: {
                        connect: {
                            Name: decodeURIComponent(args.useradd.Name)
                        }
                    }
                },
                include: {
                    wilddetail: true,
                    source: true,
                    userupd: true,
                }
            };
            upsertParams.where = {
                WID: args.WID
            };
            answer = await prisma.Wilderness.update(upsertParams);
        } else {
            upsertParams = {
                data: {
                    Name: decodeURIComponent(args.Name),
                    Description: decodeURIComponent(args.Description),
                    source: {
                        connectOrCreate: {
                            where: {
                                Name: decodeURIComponent(args.source.Name)
                            },
                            create: {
                                Name: decodeURIComponent(args.source.Name)
                            }
                        },
                    },
                    useradd: {
                        connect: {
                            Name: decodeURIComponent(args.useradd.Name)
                        }
                    }
                },
                include: {
                    source: true,
                    wilddetail: true,
                    useradd: true
                }
            };
            answer = await prisma.Wilderness.create(upsertParams);
        }
        console.log(answer);
        return answer;
    },

    setWildDetail: async (args, context) => {
        let upsertParams = null;
        let answer = null;
        if (args.WDID) {
            upsertParams = {
                data: {
                    Name: decodeURIComponent(args.Name),
                    Description: decodeURIComponent(args.Description),
                    type: {
                        connect: {
                            WID: args.type.WID
                        }
                    }
                }
            };
            upsertParams.where = {
                WDID: args.WDID
            };
            answer = await prisma.WildDetails.update(upsertParams);
        } else {
            upsertParams = {
                data: {
                    Name: decodeURIComponent(args.Name),
                    Description: decodeURIComponent(args.Description),
                    type: {
                        connect: {
                            WID: args.type.WID
                        }
                    }
                }
            };
            answer = await prisma.WildDetails.create(upsertParams);
        }
        console.log(answer);
        return answer;
    },

    setTrapType: async (args, context) => {
        let upsertParams = null;
        let answer = null;
        if (args.TTID) {
            upsertParams = {
                data: args
            };
            upsertParams.where = {
                TTID: args.TTID
            };
            answer = await prisma.TrapTypes.update(upsertParams);
        } else {
            upsertParams = {
                data: args
            };
            answer = await prisma.TrapTypes.create(upsertParams);
        }
        console.log(answer);
        return answer;
    },

    setTrapReset: async (args, context) => {
        let upsertParams = null;
        let answer = null;
        if (args.TRID) {
            upsertParams = {
                data: args
            };
            upsertParams.where = {
                TRID: args.TRID
            };
            answer = await prisma.TrapResets.update(upsertParams);
        } else {
            upsertParams = {
                data: args
            };
            answer = await prisma.TrapResets.create(upsertParams);
        }
        console.log(answer);
        return answer;
    },

    setTrapTrigger: async (args, context) => {
        let upsertParams = null;
        let answer = null;
        if (args.TTID) {
            upsertParams = {
                data: args
            };
            upsertParams.where = {
                TTID: args.TTID
            };
            answer = await prisma.TrapTriggers.update(upsertParams);
        } else {
            upsertParams = {
                data: args
            };
            answer = await prisma.TrapTriggers.create(upsertParams);
        }
        console.log(answer);
        return answer;
    },

    setTrap: async (args, context) => {
        let upsertParams = null;
        let answer = null;
        if (args.TID) {
            upsertParams = {
                data: args
            };
            upsertParams.where = {
                TID: args.TID
            };
            answer = await prisma.Traps.update(upsertParams);
        } else {
            upsertParams = {
                data: args
            };
            answer = await prisma.Traps.create(upsertParams);
        }
        console.log(answer);
        return answer;
    },

    setWeather: async (args, context) => {
        let upsertParams = null;
        let answer = null;
        if (args.WID) {
            upsertParams = {
                data: {
                    Name: decodeURIComponent(args.Name),
                    Description: decodeURIComponent(args.Description),
                    source: {
                        connectOrCreate: {
                            where: {
                                Name: decodeURIComponent(args.source.Name)
                            },
                            create: {
                                Name: decodeURIComponent(args.source.Name)
                            }
                        },
                    },
                    userupd: {
                        connect: {
                            Name: decodeURIComponent(args.useradd.Name)
                        }
                    }
                },
                include: {
                    subweather: true,
                    source: true,
                    userupd: true,
                }
            };
            upsertParams.where = {
                WID: args.WID
            };
            answer = await prisma.Weather.update(upsertParams);
        } else {
            upsertParams = {
                data: {
                    Name: decodeURIComponent(args.Name),
                    Description: decodeURIComponent(args.Description),
                    source: {
                        connectOrCreate: {
                            where: {
                                Name: decodeURIComponent(args.source.Name)
                            },
                            create: {
                                Name: decodeURIComponent(args.source.Name)
                            }
                        },
                    },
                    useradd: {
                        connect: {
                            Name: decodeURIComponent(args.useradd.Name)
                        }
                    }
                },
                include: {
                    source: true,
                    subweather: true
                }
            };
            answer = await prisma.Weather.create(upsertParams);
        }
        console.log(answer);
        return answer;
    },

    setSubweather: async (args, context) => {
        let upsertParams = null;
        let answer = null;
        if (args.SWID) {
            upsertParams = {
                data: {
                    Name: decodeURIComponent(args.Name),
                    Description: decodeURIComponent(args.Description),
                    source: {
                        connectOrCreate: {
                            where: {
                                Name: decodeURIComponent(args.source.Name)
                            },
                            create: {
                                Name: decodeURIComponent(args.source.Name)
                            }
                        },
                    },
                    class: {
                        connect: {
                            WID: args.class.WID
                        }
                    },
                    useradd: {
                        connect: {
                            Name: decodeURIComponent(args.useradd.Name)
                        }
                    }
                }
            };
            upsertParams.where = {
                SWID: args.SWID
            };
            answer = await prisma.Subweather.update(upsertParams);
        } else {
            upsertParams = {
                data: {
                    Name: decodeURIComponent(args.Name),
                    Description: decodeURIComponent(args.Description),
                    source: {
                        connectOrCreate: {
                            where: {
                                Name: decodeURIComponent(args.source.Name)
                            },
                            create: {
                                Name: decodeURIComponent(args.source.Name)
                            }
                        },
                    },
                    class: {
                        connect: {
                            WID: args.class.WID
                        }
                    },
                    useradd: {
                        connect: {
                            Name: decodeURIComponent(args.useradd.Name)
                        }
                    }
                },
                include: {
                    source: true
                }
            };
            answer = await prisma.Subweather.create(upsertParams);
        }
        console.log(answer);
        return answer;
    },

    setGod: async (args, context) => {
        let upsertParams = null;
        let answer = null;
        if (args.GID) {
            upsertParams = {
                data: args
            };
            upsertParams.where = {
                GID: args.GID
            };
            answer = await prisma.Gods.update(upsertParams);
        } else {
            upsertParams = {
                data: args
            };
            answer = await prisma.Gods.create(upsertParams);
        }
        console.log(answer);
        return answer;
    },

    setUser: async (args, context) => {
        let upsertParams = null;
        let answer = null;
        if (args.UID) {
            upsertParams = {
                data: {
                    Name: decodeURIComponent(args.Name),
                    Password: decodeURIComponent(args.Password),
                    Type: args.Type
                }
            };
            upsertParams.where = {
                UID: args.UID
            };
            answer = await prisma.Users.update(upsertParams);
        } else {
            upsertParams = {
                data: {
                    Name: decodeURIComponent(args.Name),
                    Password: decodeURIComponent(args.Password),
                    Type: args.Type
                }
            };
            answer = await prisma.Users.create(upsertParams);
        }
        console.log(answer);
        return answer;
    },

    setCampain: async (args, context) => {
        let upsertParams = null;
        let answer = null;
        if (args.GCID) {
            upsertParams = {
                data: {
                    Name: decodeURIComponent(args.Name),
                    Description: decodeURIComponent(args.Description),
                    master: {
                        connect: {
                            Name: decodeURIComponent(args.master.Name)
                        }
                    }
                },
                include: {
                    gamesessions: true,
                    master: true,
                }
            };
            upsertParams.where = {
                GCID: args.GCID
            };
            answer = await prisma.GameCampains.update(upsertParams);
        } else {
            upsertParams = {
                data: {
                    Name: decodeURIComponent(args.Name),
                    Description: decodeURIComponent(args.Description),
                    master: {
                        connect: {
                            Name: decodeURIComponent(args.master.Name)
                        }
                    }
                },
                include: {
                    gamesessions: true,
                    master: true,
                }
            };
            answer = await prisma.GameCampains.create(upsertParams);
        }
        console.log(answer);
        return answer;
    },

    setSession: async (args, context) => {
        let upsertParams = null;
        let answer = null;
        if (args.GSID) {
            upsertParams = {
                data: {
                    Name: decodeURIComponent(args.Name),
                    Description: decodeURIComponent(args.Description),
                    campain: {
                        connect: {
                            GCID: args.campain.GCID
                        }
                    }
                }
            };
            upsertParams.where = {
                GSID: args.GSID
            };
            answer = await prisma.GameSessions.update(upsertParams);
        } else {
            upsertParams = {
                data: {
                    Name: decodeURIComponent(args.Name),
                    Description: decodeURIComponent(args.Description),
                    campain: {
                        connect: {
                            GCID: args.campain.GCID
                        }
                    }
                }
            };
            answer = await prisma.GameSessions.create(upsertParams);
        }
        console.log(answer);
        return answer;
    },

    setPlayer: async (args, context) => {
        let upsertParams = null;
        let answer = null;
        if (args.PID) {
            upsertParams = {
                data: args
            };
            upsertParams.where = {
                PID: args.PID
            };
            answer = await prisma.Players.update(upsertParams);
        } else {
            upsertParams = {
                data: args
            };
            answer = await prisma.Players.create(upsertParams);
        }
        console.log(answer);
        return answer;
    },

    setCharacter: async (args, context) => {
        let upsertParams = null;
        let answer = null;
        if (args.CID) {
            upsertParams = {
                data: args
            };
            upsertParams.where = {
                CID: args.CID
            };
            answer = await prisma.Characters.update(upsertParams);
        } else {
            upsertParams = {
                data: args
            };
            answer = await prisma.Characters.create(upsertParams);
        }
        console.log(answer);
        return answer;
    },

    delUserMemory: async (args, context) => {
        let temp = await prisma.UserMemory.findFirst({
            where: {
                AND: [{
                        UID: args.UID
                    },
                    {
                        TableID: args.TableID
                    },
                    {
                        TableName: decodeURIComponent(args.TableName)
                    }
                ]
            }
        });
        let answer = await prisma.UserMemory.delete({
            where: {
                UMID: temp.UMID
            }
        });
        console.log(answer);
        return answer;
    },

    delRequest: async (args, context) => {
        let answer = await prisma.Requests.delete({
            where: {
                RID: args.RID
            }
        });
        console.log(answer);
        return answer;
    },

    delSource: async (args, context) => {
        let answer = await prisma.Source.delete({
            where: {
                SID: args.SID
            }
        });
        console.log(answer);
        return answer;
    },

    delImages: async (args, context) => {
        let answer = await prisma.Images.delete({
            where: {
                IID: args.IID
            }
        });
        console.log(answer);
        return answer;
    },

    delBasicAbilities: async (args, context) => {
        let answer = await prisma.BasicAbilities.delete({
            where: {
                BAID: args.BAID
            }
        });
        console.log(answer);
        return answer;
    },

    delMonsters: async (args, context) => {
        let answer = await prisma.Monsters.delete({
            where: {
                MID: args.MID
            }
        });
        console.log(answer);
        return answer;
    },

    delMonsterTypes: async (args, context) => {
        let answer = await prisma.MonsterTypes.delete({
            where: {
                MTID: args.MTID
            }
        });
        console.log(answer);
        return answer;
    },

    delFeatTypes: async (args, context) => {
        let answer = await prisma.FeatTypes.delete({
            where: {
                FTID: args.FTID
            }
        });
        console.log(answer);
        return answer;
    },

    delFeats: async (args, context) => {
        let answer = await prisma.Feats.delete({
            where: {
                FID: args.FID
            }
        });
        console.log(answer);
        return answer;
    },

    delAlignments: async (args, context) => {
        let answer = await prisma.Alignments.delete({
            where: {
                AID: args.AID
            }
        });
        console.log(answer);
        return answer;
    },

    delClassFeatures: async (args, context) => {
        let answer = await prisma.ClassFeatures.delete({
            where: {
                CFID: args.CFID
            }
        });
        console.log(answer);
        return answer;
    },

    delSkills: async (args, context) => {
        let answer = await prisma.Skills.delete({
            where: {
                SID: args.SID
            }
        });
        console.log(answer);
        return answer;
    },

    delClasses: async (args, context) => {
        let answer = await prisma.Classes.delete({
            where: {
                CID: args.CID
            }
        });
        console.log(answer);
        return answer;
    },

    delRaces: async (args, context) => {
        let answer = await prisma.Races.delete({
            where: {
                RID: args.RID
            }
        });
        console.log(answer);
        return answer;
    },

    delEquipmentTypes: async (args, context) => {
        let answer = await prisma.EquipmentTypes.delete({
            where: {
                ETID: args.ETID
            }
        });
        console.log(answer);
        return answer;
    },

    delEquipment: async (args, context) => {
        let answer = await prisma.Equipment.delete({
            where: {
                EID: args.EID
            }
        });
        console.log(answer);
        return answer;
    },

    delSpellTypes: async (args, context) => {
        let answer = await prisma.SpellTypes.delete({
            where: {
                STID: args.STID
            }
        });
        console.log(answer);
        return answer;
    },

    delMagicSubschools: async (args, context) => {
        let answer = await prisma.MagicSubschools.delete({
            where: {
                MSID: args.MSID
            }
        });
        console.log(answer);
        return answer;
    },

    delMagicSchools: async (args, context) => {
        let answer = await prisma.MagicSchools.delete({
            where: {
                MSID: args.MSID
            }
        });
        console.log(answer);
        return answer;
    },

    delSpellComponents: async (args, context) => {
        let answer = await prisma.SpellComponents.delete({
            where: {
                SCID: args.SCID
            }
        });
        console.log(answer);
        return answer;
    },

    delSpells: async (args, context) => {
        let answer = await prisma.Spells.delete({
            where: {
                SID: args.SID
            }
        });
        console.log(answer);
        return answer;
    },

    delRules: async (args, context) => {
        let answer = await prisma.Rules.delete({
            where: {
                RID: args.RID
            }
        });
        console.log(answer);
        return answer;
    },

    delMagicEffects: async (args, context) => {
        let answer = await prisma.MagicEffects.delete({
            where: {
                MEID: args.MEID
            }
        });
        console.log(answer);
        return answer;
    },

    delMagicItems: async (args, context) => {
        let answer = await prisma.MagicItems.delete({
            where: {
                MIID: args.MIID
            }
        });
        console.log(answer);
        return answer;
    },

    delDungeonTypes: async (args, context) => {
        let answer = await prisma.DungeonTypes.delete({
            where: {
                DTID: args.DTID
            }
        });
        console.log(answer);
        return answer;
    },

    delDungeonElements: async (args, context) => {
        let answer = await prisma.DungeonElements.delete({
            where: {
                DEID: args.DEID
            }
        });
        console.log(answer);
        return answer;
    },

    delDungeonSubelements: async (args, context) => {
        let answer = await prisma.DungeonSubelements.delete({
            where: {
                DSID: args.DSID
            }
        });
        console.log(answer);
        return answer;
    },

    delSiegeEngines: async (args, context) => {
        let answer = await prisma.SiegeEngines.delete({
            where: {
                SEID: args.SEID
            }
        });
        console.log(answer);
        return answer;
    },

    delHazards: async (args, context) => {
        let answer = await prisma.Hazards.delete({
            where: {
                HID: args.HID
            }
        });
        console.log(answer);
        return answer;
    },

    delWilderness: async (args, context) => {
        let answer = await prisma.Wilderness.delete({
            where: {
                WID: args.WID
            }
        });
        console.log(answer);
        return answer;
    },

    delWildDetails: async (args, context) => {
        let answer = await prisma.WildDetails.delete({
            where: {
                WDID: args.WDID
            }
        });
        console.log(answer);
        return answer;
    },

    delTrapTypes: async (args, context) => {
        let answer = await prisma.TrapTypes.delete({
            where: {
                TTID: args.TTID
            }
        });
        console.log(answer);
        return answer;
    },

    delTrapResets: async (args, context) => {
        let answer = await prisma.TrapResets.delete({
            where: {
                TRID: args.TRID
            }
        });
        console.log(answer);
        return answer;
    },

    delTrapTriggers: async (args, context) => {
        let answer = await prisma.TrapTriggers.delete({
            where: {
                TTID: args.TTID
            }
        });
        console.log(answer);
        return answer;
    },

    delTraps: async (args, context) => {
        let answer = await prisma.Traps.delete({
            where: {
                TID: args.TID
            }
        });
        console.log(answer);
        return answer;
    },

    delWeather: async (args, context) => {
        let answer = await prisma.Weather.delete({
            where: {
                WID: args.WID
            }
        });
        console.log(answer);
        return answer;
    },

    delSubweather: async (args, context) => {
        let answer = await prisma.Subweather.delete({
            where: {
                SWID: args.SWID
            }
        });
        console.log(answer);
        return answer;
    },

    delGods: async (args, context) => {
        let answer = await prisma.Gods.delete({
            where: {
                GID: args.GID
            }
        });
        console.log(answer);
        return answer;
    },

    delUsers: async (args, context) => {
        let answer = await prisma.Users.delete({
            where: {
                UID: args.UID
            }
        });
        console.log(answer);
        return answer;
    },

    delGameCampains: async (args, context) => {
        let answer = await prisma.GameCampains.delete({
            where: {
                GCID: args.GCID
            }
        });
        console.log(answer);
        return answer;
    },

    delGameSessions: async (args, context) => {
        let answer = await prisma.GameSessions.delete({
            where: {
                GSID: args.GSID
            }
        });
        console.log(answer);
        return answer;
    },

    delPlayers: async (args, context) => {
        let answer = await prisma.Players.delete({
            where: {
                PID: args.PID
            }
        });
        console.log(answer);
        return answer;
    },

    delCharacters: async (args, context) => {
        let answer = await prisma.Characters.delete({
            where: {
                CID: args.CID
            }
        });
        console.log(answer);
        return answer;
    },

    /*newRequest: {
        subscribe: () => prisma.requests.findMany(), // Подписываемся на все новые записи в таблице Requests
        resolve: (payload) => payload, // Отправляем полученные данные в клиент
    },*/
    requests: {
        resolve: (payload) => payload,
        subscribe: () => pubsub.asyncIterator('requests'),

    },
    /*updatedRequest: {
        subscribe: () => prisma.$subscribe.requests(), // Подписываемся на изменения в таблице Requests
        resolve: (payload) => payload, // Отправляем полученные данные в клиент
    }*/

};

module.exports = resolver;