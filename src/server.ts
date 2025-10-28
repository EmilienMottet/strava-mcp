import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import * as dotenv from "dotenv";
import path from "path";
import { fileURLToPath } from "url";

// Import all tool definitions with the correct names
import { getAthleteProfile } from './tools/getAthleteProfile.js';
import { getAthleteStatsTool } from "./tools/getAthleteStats.js";
import { getActivityDetailsTool } from "./tools/getActivityDetails.js";
import { getRecentActivities } from "./tools/getRecentActivities.js";
import { listAthleteClubs } from './tools/listAthleteClubs.js';
import { listStarredSegments } from './tools/listStarredSegments.js';
import { getSegmentTool } from "./tools/getSegment.js";
import { exploreSegments } from './tools/exploreSegments.js';
import { starSegment } from './tools/starSegment.js';
import { getSegmentEffortTool } from './tools/getSegmentEffort.js';
import { listSegmentEffortsTool } from './tools/listSegmentEfforts.js';
import { listAthleteRoutesTool } from './tools/listAthleteRoutes.js';
import { getRouteTool } from './tools/getRoute.js';
import { exportRouteGpx } from './tools/exportRouteGpx.js';
import { exportRouteTcx } from './tools/exportRouteTcx.js';
import { getActivityStreamsTool } from './tools/getActivityStreams.js';
import { getActivityLapsTool } from './tools/getActivityLaps.js';
import { getAthleteZonesTool } from './tools/getAthleteZones.js';
import { getAllActivities } from './tools/getAllActivities.js';

// Import the actual client function
// import {
//     // exportRouteGpx as exportRouteGpxClient, // Removed unused alias
//     // exportRouteTcx as exportRouteTcxClient, // Removed unused alias
//     getActivityLaps as getActivityLapsClient
// } from './stravaClient.js';

// Load .env file explicitly from project root
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const projectRoot = path.resolve(__dirname, '..');
const envPath = path.join(projectRoot, '.env');
// REMOVE THIS DEBUG LOG - Interferes with MCP Stdio transport
// console.log(`[DEBUG] Attempting to load .env file from: ${envPath}`);
dotenv.config({ path: envPath });

const server = new McpServer({
  name: "Strava MCP Server",
  version: "1.0.0"
});

// Register all tools using server.tool and the correct imported objects
server.tool(
    getAthleteProfile.name,
    getAthleteProfile.description,
    {},
    getAthleteProfile.execute
);
server.tool(
    getAthleteStatsTool.name, 
    getAthleteStatsTool.description,
    getAthleteStatsTool.inputSchema?.shape ?? {},
    getAthleteStatsTool.execute
);
server.tool(
    getActivityDetailsTool.name, 
    getActivityDetailsTool.description,
    getActivityDetailsTool.inputSchema?.shape ?? {},
    getActivityDetailsTool.execute
);
server.tool(
    getRecentActivities.name,
    getRecentActivities.description,
    getRecentActivities.inputSchema?.shape ?? {},
    getRecentActivities.execute
);
server.tool(
    listAthleteClubs.name,
    listAthleteClubs.description,
    {},
    listAthleteClubs.execute
);
server.tool(
    listStarredSegments.name,
    listStarredSegments.description,
    {},
    listStarredSegments.execute
);
server.tool(
    getSegmentTool.name, 
    getSegmentTool.description,
    getSegmentTool.inputSchema?.shape ?? {},
    getSegmentTool.execute
);
server.tool(
    exploreSegments.name,
    exploreSegments.description,
    exploreSegments.inputSchema?.shape ?? {},
    exploreSegments.execute
);
server.tool(
    starSegment.name,
    starSegment.description,
    starSegment.inputSchema?.shape ?? {},
    starSegment.execute
);
server.tool(
    getSegmentEffortTool.name, 
    getSegmentEffortTool.description,
    getSegmentEffortTool.inputSchema?.shape ?? {},
    getSegmentEffortTool.execute
);
server.tool(
    listSegmentEffortsTool.name, 
    listSegmentEffortsTool.description,
    listSegmentEffortsTool.inputSchema?.shape ?? {},
    listSegmentEffortsTool.execute
);
server.tool(
    listAthleteRoutesTool.name, 
    listAthleteRoutesTool.description,
    listAthleteRoutesTool.inputSchema?.shape ?? {},
    listAthleteRoutesTool.execute
);
server.tool(
    getRouteTool.name,
    getRouteTool.description,
    getRouteTool.inputSchema?.shape ?? {},
    getRouteTool.execute
);
server.tool(
    exportRouteGpx.name,
    exportRouteGpx.description,
    exportRouteGpx.inputSchema?.shape ?? {},
    exportRouteGpx.execute
);
server.tool(
    exportRouteTcx.name,
    exportRouteTcx.description,
    exportRouteTcx.inputSchema?.shape ?? {},
    exportRouteTcx.execute
);
server.tool(
    getActivityStreamsTool.name,
    getActivityStreamsTool.description,
    getActivityStreamsTool.inputSchema?.shape ?? {},
    getActivityStreamsTool.execute
);

// --- Register get-activity-laps tool (Simplified) ---
server.tool(
    getActivityLapsTool.name, 
    getActivityLapsTool.description,
    getActivityLapsTool.inputSchema?.shape ?? {},
    getActivityLapsTool.execute
);

// --- Register get-athlete-zones tool ---
server.tool(
    getAthleteZonesTool.name, 
    getAthleteZonesTool.description,
    getAthleteZonesTool.inputSchema?.shape ?? {},
    getAthleteZonesTool.execute
);

// --- Register get-all-activities tool ---
server.tool(
    getAllActivities.name,
    getAllActivities.description,
    getAllActivities.inputSchema?.shape ?? {},
    getAllActivities.execute
);

// --- Helper Functions ---
// Moving formatDuration to utils or keeping it here if broadly used.
// For now, it's imported by getActivityLaps.ts
export function formatDuration(seconds: number): string {
    if (isNaN(seconds) || seconds < 0) {
        return 'N/A';
    }
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const secs = Math.floor(seconds % 60);

    const parts: string[] = [];
    if (hours > 0) {
        parts.push(hours.toString().padStart(2, '0'));
    }
    parts.push(minutes.toString().padStart(2, '0'));
    parts.push(secs.toString().padStart(2, '0'));

    return parts.join(':');
}

// Removed other formatters - they are now local to their respective tools.

// --- Server Startup ---
async function startServer() {
  try {
    const useHttp = process.env.USE_HTTP === 'true';
    
    if (useHttp) {
      // HTTP Streamable transport for Docker deployment
      const { StreamableHTTPServerTransport } = await import("@modelcontextprotocol/sdk/server/streamableHttp.js");
      const express = (await import('express')).default;
      
      const port = parseInt(process.env.PORT || '3000');
      const app = express();
      
      // Important: Add JSON body parser middleware
      app.use(express.json());
      
      console.error(`Starting Strava MCP Server on HTTP port ${port}...`);
      
      // Store active transports by session
      const transports = new Map<string, any>();
      
      // Health check endpoint
      app.get('/health', (_req, res) => {
        res.json({ 
          status: 'ok', 
          name: 'Strava MCP Server',
          version: '1.0.0',
          transport: 'StreamableHTTP'
        });
      });
      
      // Streamable HTTP endpoint - handles POST messages
      app.post('/message', async (req, res) => {
        console.error('New StreamableHTTP POST request received');
        
        try {
          const requestedSessionId = req.body?.sessionId || req.headers['mcp-session-id'] || 'default';
          
          // Get or create transport for this session
          let transport = transports.get(requestedSessionId);
          if (!transport) {
            console.error(`Creating new transport for session: ${requestedSessionId}`);
            transport = new StreamableHTTPServerTransport({
              sessionIdGenerator: () => requestedSessionId,
              onsessioninitialized: async (sessionId) => {
                console.error(`Session initialized: ${sessionId}`);
              },
              onsessionclosed: async (sessionId) => {
                console.error(`Session closed: ${sessionId}`);
                transports.delete(sessionId);
              }
            });
            transports.set(requestedSessionId, transport);
            
            // Connect server to transport
            await server.connect(transport);
          }
          
          // Handle the incoming request (not handlePostMessage)
          await transport.handleRequest(req, res, req.body);
          
        } catch (error) {
          console.error('Error handling message:', error);
          if (!res.headersSent) {
            res.status(500).json({ error: 'Internal server error' });
          }
        }
      });
      
      // Legacy SSE endpoint for backward compatibility (optional)
      app.get('/sse', async (_req, res) => {
        console.error('⚠️  SSE endpoint called but deprecated. Use StreamableHTTP /message instead.');
        res.status(404).json({ 
          error: 'SSE transport is deprecated',
          message: 'Please use StreamableHTTP transport at /message endpoint'
        });
      });
      
      app.listen(port, () => {
        console.error(`Strava MCP Server listening on port ${port}`);
        console.error(`Health check: http://localhost:${port}/health`);
        console.error(`StreamableHTTP endpoint: http://localhost:${port}/message`);
      });
    } else {
      // Stdio transport for local development
      console.error("Starting Strava MCP Server via stdio...");
      const transport = new StdioServerTransport();
      await server.connect(transport);
      console.error(`Strava MCP Server connected via Stdio. Tools registered.`);
    }
  } catch (error) {
    console.error("Failed to start server:", error);
    process.exit(1);
  }
}

startServer();